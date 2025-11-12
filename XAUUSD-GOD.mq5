//+------------------------------------------------------------------+
//|                                                  XAUUSD-GOD.mq5 |
//|                                      XAUUSD Algorithmic Trading |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "XAUUSD-GOD"
#property link      ""
#property version   "1.00"
#property strict

#include <inc/types.mqh>
#include <inc/constants.mqh>
#include <inc/config_inputs.mqh>
#include <inc/utils.mqh>
#include <inc/logging.mqh>
#include <inc/indicators.mqh>
#include <inc/regime.mqh>
#include <inc/filters.mqh>
#include <inc/spread_vol_filter.mqh>
#include <inc/range_detector.mqh>
#include <inc/liquidity_sweep.mqh>
#include <inc/breakout.mqh>
#include <inc/risk.mqh>
#include <inc/orders.mqh>
#include <inc/trade_manager.mqh>

input group "XAUUSD-GOD Settings"

datetime g_lastBar_M5 = 0;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
{
  LogInit("XAUUSD-GOD");
  const string sym = _Symbol;
  const ENUM_TIMEFRAMES tf = PERIOD_CURRENT;

  if(!InitIndicators(sym, tf))
  {
    LogError("INIT","InitIndicators failed", GetLastError());
    return(INIT_FAILED);
  }

  int stops_level, freeze_level;
  if(!SymbolInfoInteger(sym, SYMBOL_TRADE_MODE)) 
  { 
    LogError("INIT","SymbolInfoInteger failed", GetLastError()); 
  }

  datetime t0 = iTime(sym, PERIOD_M5, 0);
  if(t0 > 0) g_lastBar_M5 = t0;

  LogEvent("INIT","OK");
  return(INIT_SUCCEEDED);
}

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
  FreeIndicators();
  LogEvent("DEINIT","done");
}

//+------------------------------------------------------------------+
//| Pre-trade gate check                                             |
//+------------------------------------------------------------------+
bool PreTradeGate(const datetime server_time)
{
  if(!TM_DD_GateOK())        return false;
  if(!CanTradeNow(_Symbol, server_time)) return false;
  return true;
}

//+------------------------------------------------------------------+
//| Build signal based on regime                                     |
//+------------------------------------------------------------------+
bool BuildSignal(Signal &out_sig)
{
  out_sig.valid = false; 
  out_sig.dir = DIR_NONE; 
  out_sig.entry = 0.0;
  out_sig.sl = 0.0;
  out_sig.tp = 0.0;
  out_sig.reason = "";

  Regime r = DetectRegime();
  if(r == REGIME_RANGE)
  {
    Signal s = ScanAndSignal_LiquiditySweep();
    if(s.valid)
    {
      out_sig = s;
      return true;
    }
    return false;
  }
  else
  {
    Signal s = ScanAndSignal_Breakout();
    if(s.valid)
    {
      out_sig = s;
      return true;
    }
    return false;
  }
}

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
{
  const datetime now = TimeCurrent();

  TM_DD_Update(now);

  TM_ManageOpenPositions();

  if(!NewBarGuard(PERIOD_M5, g_lastBar_M5)) return;

  if(!PreTradeGate(now)) return;

  Signal sig;
  if(!BuildSignal(sig) || !sig.valid) return;

  double lot = ComputeLot((sig.entry > 0.0 ? sig.entry : 0.0), sig.sl);
  if(lot <= 0.0) 
  { 
    LogEvent("TRADE","lot=0; skip"); 
    return; 
  }

  ulong ticket = 0;
  bool sent = false;

  if(sig.reason == REASON_LIQ_SWEEP)
  {
    sent = ExecuteMarketOrder(sig, lot, ticket);
  }
  else if(sig.reason == REASON_TREND_BO)
  {
    sent = ExecutePendingOrder(sig, lot, Order_Expiration_Min, ticket);
  }
  else
  {
    LogEvent("TRADE","unknown reason; skip");
    return;
  }

  if(sent)
    LogEvent("TRADE","sent ok; ticket=" + (string)ticket + " reason=" + sig.reason);
  else
    LogError("TRADE","send failed", GetLastError());
}
//+------------------------------------------------------------------+
