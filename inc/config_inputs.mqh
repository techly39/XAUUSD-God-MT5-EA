#ifndef INC_CONFIG_INPUTS_MQH
#define INC_CONFIG_INPUTS_MQH

// ================== CORE INDICATORS (M15 SCALPING) ==================
input int    EMA_Trend_Period      = 200;  // Higher-timeframe trend bias
input int    EMA_Intraday_Period   = 50;   // Intraday bias (M15)
input int    ADX_Period            = 14;   // Standard ADX length
input double ADX_Trend_Threshold   = 25.0; // FIXED: Was 35, PDF says 25
input int    RSI_Period            = 14;   // Momentum confirm
input int    RSI_Buy_Threshold     = 35;   // FIXED: Was 28, relaxed per PDF
input int    RSI_Sell_Threshold    = 70;   // FIXED: Was 72, relaxed per PDF
input int    RSI_Exit              = 50;   // RSI exit level
input int    ATR_Period            = 14;   // Volatility baseline (M15)

// ================== BREAKOUT ENGINE (DONCHIAN-STYLE, M15) ==================
input int    Breakout_Lookback          = 20;    // 20 x 15min ≈ 5h
input int    Breakout_CloseBeyond_Points= 3;     // FIXED: Was 0, now 3 pts (0.03 XAUUSD)
input int    Pending_Offset_Points      = 5;     // FIXED: Was 10, now 5 (0.05 XAUUSD)
input bool   Breakout_Use_ADX_Filter    = false; // Optional ADX filter
input bool   Breakout_Use_Volume_Filter = false; // Optional volume filter
input int    Vol_MA_Period              = 20;    // Tick-volume baseline
input double Vol_Min_Ratio              = 1.5;   // Breakout bar >= 150% vol-MA

// ================== LIQUIDITY-SWEEP ENGINE (RANGE REVERSAL, M15) ==================
input int    Range_Lookback_Bars   = 12;   // ~3h range on M15
input int    Range_Min_Width_Points= 100;  // FIXED: Was 50, now 100 (realistic for M15)
input int    Range_Max_Width_Points= 800;  // Maximum range width
input int    Sweep_Buffer_Points   = 20;   // FIXED: Was 10, now 20 (0.20 XAUUSD)
input int    Sweep_Reentry_Confirm_Bars = 1; // FIXED: Was 2, now 1 (faster entry)
input bool   Sweep_Use_RSI_Confirm = false; // DISABLED for testing

// ================== SESSION FILTERS ==================
input bool   Use_Session_Filter = true;
input int    Session_Start_Hour  = 0;    // FIXED: Was 7, now 0 (full 24h)
input int    Session_End_Hour    = 23;   // FIXED: Was 18, now 23 (full 24h)

// ================== RISK / SIZING ==================
input int    Risk_Mode                  = 0;    // 0=Fixed lot, 1=Percent risk
input double Risk_Percent               = 2.0;  // Per-trade risk
input double Fixed_Lot                  = 0.01; // Fixed lot size
input double Max_Daily_Drawdown_Percent = 5.0;  // Max daily DD

// ================== STOPS / TARGETS (M15 GOLD) ==================
input double ATR_Mult_SL_Trend = 1.50; // Trend breakout SL
input double ATR_Mult_SL_Range = 1.20; // Sweep reversal SL

// ================== EXECUTION GATES ==================
input int    Min_ATR_Points     = 50;   // FIXED: Was 100, now 50 (less restrictive)
input int    Max_Spread_Points  = 1500; // Max spread

// ================== MANAGEMENT (BE / TRAIL / PARTIAL) ==================
input int    Trail_Mode             = 2;    // 0=Off, 1=Fixed, 2=ATR
input int    Trail_Start_Points     = 150;  // Start trailing
input int    Trail_Step_Points      = 120;  // Fixed trail step
input double Trail_ATR_Mult         = 1.00; // ATR trailing multiplier

input int    Move_BE_After_Points   = 150;  // Move to BE after +15 pips
input bool   Use_Partials           = true;
input double Partial1_Ratio         = 0.50; // Close 50% at target
input int    Partial1_Target_Points = 200;  // +20 pips partial

// ================== PROFIT TARGETS ==================
input int    TP_Mode         = 1;   // 0=Fixed, 1=RR
input int    TP_Fixed_Points = 200; // Fixed TP
input double RR_Target       = 2.0; // Risk:Reward ratio

// ================== HOUSEKEEPING ==================
input int    Magic_Offset          = 1;
input int    Max_Slippage_Points   = 50;
input int    Order_Expiration_Min  = 30;
input string Order_Comment         = "XAUUSD-GOD-M15";

// ================== TRADING SCHEDULE ==================
input bool   Trading_Day_Mon = true;
input bool   Trading_Day_Tue = true;
input bool   Trading_Day_Wed = true;
input bool   Trading_Day_Thu = true;
input bool   Trading_Day_Fri = true;
input string Friday_CloseTime = "21:00";

// ================== MISC ==================
input bool   Only_New_Bar = true;
input int    Order_Type   = 0; // 0=Market, 1=Pending

#endif // INC_CONFIG_INPUTS_MQH
