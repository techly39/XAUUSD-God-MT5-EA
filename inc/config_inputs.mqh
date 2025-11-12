#ifndef INC_CONFIG_INPUTS_MQH
#define INC_CONFIG_INPUTS_MQH

// ================== CORE INDICATORS (M15 SCALPING) ==================
input int    EMA_Trend_Period      = 200;  // Higher-timeframe trend bias (structural)
input int    EMA_Intraday_Period   = 50;   // Intraday bias (M15)
input int    ADX_Period            = 14;   // Standard ADX length
input double ADX_Trend_Threshold   = 25.0; // Trend gate threshold (trend mode if >= 25)
input int    RSI_Period            = 14;   // Momentum confirm / exhaustion
input int    RSI_Buy_Threshold     = 28;   // Aggressive but realistic for M15
input int    RSI_Sell_Threshold    = 72;   // Aggressive but realistic for M15
input int    RSI_Exit              = 50;   // RSI exit level
input int    ATR_Period            = 14;   // Volatility baseline (M15)

// ================== BREAKOUT ENGINE (DONCHIAN-STYLE, M15) ==================
input int    Breakout_Lookback          = 20;    // Recent high/low window (20 x 15min ≈ 5h)
input int    Breakout_CloseBeyond_Points= 30;    // Close must be beyond channel (0.3x ATR placeholder)
input int    Pending_Offset_Points      = 20;    // Stop order offset (0.2x ATR placeholder)
input bool   Breakout_Use_ADX_Filter    = true;  // Require ADX >= ADX_Min_Trend
input bool   Breakout_Use_Volume_Filter = true;  // Require volume spike vs MA
input int    Vol_MA_Period              = 20;    // Tick-volume baseline (20 bars ≈ 5h)
input double Vol_Min_Ratio              = 1.5;   // Breakout bar >= 150% vol-MA

// ================== LIQUIDITY-SWEEP ENGINE (RANGE REVERSAL, M15) ==================
input int    Range_Lookback_Bars   = 12;   // ~3h range on M15 (good for Asian box / pre-London)
input int    Range_Min_Width_Points= 100;  // Minimum range width
input int    Range_Max_Width_Points= 800;  // Maximum range width
input int    Sweep_Buffer_Points   = 25;   // Wick must pierce prior H/L (0.25x ATR placeholder)
input int    Sweep_Reentry_Confirm_Bars = 2; // Bars to confirm reversal
input bool   Sweep_Use_RSI_Confirm = true; // RSI(14) <28 long / >72 short

// ================== SESSION FILTERS (OPTIONAL BUT RECOMMENDED) ==================
input bool   Use_Session_Filter = true;
input int    Session_Start_Hour  = 7;   // e.g. 07:00 server (pre-London open)
input int    Session_End_Hour    = 18;  // e.g. 18:00 server (NY overlap)

// ================== RISK / SIZING ==================
input int    Risk_Mode                  = 1;    // 0=Fixed lot, 1=Percent risk
input double Risk_Percent               = 2.0;  // Per-trade risk on account balance
input double Fixed_Lot                  = 0.10; // Used only if Risk_FixedLot
input double Max_Daily_Drawdown_Percent = 5.0;  // Max daily drawdown

// ================== STOPS / TARGETS (M15 GOLD) ==================
input double ATR_Mult_SL_Trend = 1.50; // Trend breakout SL ≈ 1.5 x ATR(14)
input double ATR_Mult_SL_Range = 1.20; // Sweep reversal SL slightly tighter

// ================== EXECUTION GATES ==================
input int    Min_ATR_Points     = 200; // Require minimum ATR (M15) to avoid dead sessions
input int    Max_Spread_Points  = 40;  // Cap poor liquidity; 30–40 OK for gold scalping

// ================== MANAGEMENT (BE / TRAIL / PARTIAL) ==================
input int    Trail_Mode             = 2;    // 0=Off, 1=Fixed step, 2=ATR
input int    Trail_Start_Points     = 150;  // Start trailing
input int    Trail_Step_Points      = 120;  // Used only if Trail_Mode=1
input double Trail_ATR_Mult         = 1.00; // 1x ATR trailing stop for Mode=2

input int    Move_BE_After_Points   = 150;  // Move SL to BE after +15 pips
input bool   Use_Partials           = true;
input double Partial1_Ratio         = 0.50; // Close 50% at first target
input int    Partial1_Target_Points = 200;  // At +20 pips do partial + lock in BE

// ================== PROFIT TARGETS ==================
input int    TP_Mode         = 1;   // 0=Fixed, 1=RR ratio
input int    TP_Fixed_Points = 200; // Fixed TP
input double RR_Target       = 1.5; // Risk:Reward ratio

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
