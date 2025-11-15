//+------------------------------------------------------------------+
//|                                              liquidity_sweep.mqh |
//|                                         XAUUSD-GOD Expert Advisor |
//+------------------------------------------------------------------+
#ifndef INC_LIQUIDITY_SWEEP_MQH
#define INC_LIQUIDITY_SWEEP_MQH

#include "types.mqh"
#include "config_inputs.mqh"
#include "constants.mqh"
#include "indicators.mqh"
#include "range_detector.mqh"
#include "filters.mqh"

//+------------------------------------------------------------------+
//| Scan and generate liquidity sweep signal                         |
//+------------------------------------------------------------------+
Signal ScanAndSignal_LiquiditySweep()
{
   double box_high = 0.0;
   double box_low = 0.0;
   
   if(!BuildRangeBox(Range_Lookback_Bars, box_high, box_low))
   {
      return Signal();
   }
   
   double o = iOpen(_Symbol, PERIOD_CURRENT, 1);
   double h = iHigh(_Symbol, PERIOD_CURRENT, 1);
   double l = iLow(_Symbol, PERIOD_CURRENT, 1);
   double c = iClose(_Symbol, PERIOD_CURRENT, 1);
   
   if(o == 0.0 || o == EMPTY_VALUE || 
      h == 0.0 || h == EMPTY_VALUE || 
      l == 0.0 || l == EMPTY_VALUE || 
      c == 0.0 || c == EMPTY_VALUE)
   {
      return Signal();
   }
   
   double point = SymbolInfoDouble(_Symbol, SYMBOL_POINT);
   if(point == 0.0)
   {
      return Signal();
   }
   
   double sweep_hi = box_high + (Sweep_Buffer_Points * point);
   double sweep_lo = box_low - (Sweep_Buffer_Points * point);
   
   Direction dir = DIR_NONE;
   bool is_short_candidate = (h > sweep_hi) && (c < box_high);
   bool is_long_candidate = (l < sweep_lo) && (c > box_low);
   
   if(is_short_candidate && !is_long_candidate)
   {
      dir = DIR_SHORT;
   }
   else if(is_long_candidate && !is_short_candidate)
   {
      dir = DIR_LONG;
   }
   else
   {
      return Signal();
   }
   
   if(RSI_Buy_Threshold > 0 || RSI_Sell_Threshold > 0)
   {
      if(!RSIConfirm(dir))
      {
         return Signal();
      }
   }
   
   if(Vol_MA_Period > 0 && Vol_Min_Ratio > 0.0)
   {
      if(!VolumeConfirm())
      {
         return Signal();
      }
   }
   
   double atr = ATR(1);
   if(atr == EMPTY_VALUE || atr == 0.0)
   {
      return Signal();
   }
   
   double atr_points = atr / point;
   int sl_points = (int)MathRound(ATR_Mult_SL_Range * atr_points);
   sl_points = (int)MathMax((double)MIN_SL_POINTS, (double)sl_points);
   double sl_price_dist = sl_points * point;
   
   double entry = c;
   double sl_level = 0.0;
   double tp = 0.0;
   
   if(dir == DIR_LONG)
   {
      sl_level = MathMin(l, box_low) - sl_price_dist;
      
      // FIXED: Use enum names instead of integers
      if(TP_Mode == TP_FIXED && TP_Fixed_Points > 0)
      {
         tp = entry + (TP_Fixed_Points * point);
      }
      else if(TP_Mode == TP_RR && RR_Target > 0.0)
      {
         tp = entry + (RR_Target * sl_points * point);
      }
   }
   else if(dir == DIR_SHORT)
   {
      sl_level = MathMax(h, box_high) + sl_price_dist;
      
      // FIXED: Use enum names instead of integers
      if(TP_Mode == TP_FIXED && TP_Fixed_Points > 0)
      {
         tp = entry - (TP_Fixed_Points * point);
      }
      else if(TP_Mode == TP_RR && RR_Target > 0.0)
      {
         tp = entry - (RR_Target * sl_points * point);
      }
   }
   
   Signal s;
   s.valid = true;
   s.dir = dir;
   s.entry = entry;
   s.sl = sl_level;
   s.tp = tp;
   s.reason = REASON_LIQ_SWEEP;
   
   return s;
}

#endif // INC_LIQUIDITY_SWEEP_MQH




