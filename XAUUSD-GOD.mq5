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

  // Verify trading is allowed
  if(!SymbolInfoInteger(sym, SYMBOL_TRADE_MODE)) 
  { 
    LogError("INIT","Trading not allowed for symbol", GetLastError()); 
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

  // ADDED: Diagnostic logging for gate failures
  if(!PreTradeGate(now)) 
  {
    int spread = (int)SymbolInfoInteger(_Symbol, SYMBOL_SPREAD);
    double dd = DD_CurrentPercent();  // Function from trade_manager.mqh
    double atr_val = ATR(1);
    string reason = "";
    
    if(!TM_DD_GateOK())
    {
      reason += "DD=" + DoubleToString(dd, 2) + "% ";
    }
    
    reason += "Spread=" + IntegerToString(spread);
    if(atr_val != EMPTY_VALUE)
      reason += " ATR=" + DoubleToString(atr_val, 2);
    
    LogEvent("GATE", "Blocked: " + reason);
    return;
  }

  Signal sig;
  
  // ADDED: Diagnostic logging for signal failures
  if(!BuildSignal(sig) || !sig.valid) 
  {
    Regime r = DetectRegime();
    double adx_val = ADX(1);
    string regime_str = (r == REGIME_RANGE ? "RANGE" : "TREND");
    string msg = "No signal - Regime=" + regime_str;
    
    if(adx_val != EMPTY_VALUE)
      msg += " ADX=" + DoubleToString(adx_val, 2);
    
    LogEvent("SIGNAL", msg);
    return;
  }

  // FIXED: Get current market price for lot calculation
  MqlTick tick;
  if(!SymbolInfoTick(_Symbol, tick))
  {
    LogEvent("TRADE", "tick fail");
    return;
  }

  // Use entry price for pending orders, current price for market orders
  double ref_price = (sig.entry > 0.0) ? sig.entry : ((sig.dir == DIR_LONG) ? tick.ask : tick.bid);
  
  // FIXED: Validate signal SL before lot calculation
  if(sig.sl <= 0.0 || sig.sl == EMPTY_VALUE)
  {
    LogError("TRADE", "Invalid SL=" + DoubleToString(sig.sl, 5), 0);
    return;
  }

  double lot = ComputeLot(ref_price, sig.sl);
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


