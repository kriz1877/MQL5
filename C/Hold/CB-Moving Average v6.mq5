//+------------------------------------------------------------------+
//|                                                          CB-.mq5 |
//|                                                            Chris |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Chris"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#include <CustomFunctions.mqh>

//+------------------------------------------------------------------+
//| indicator properties                                             |
//+------------------------------------------------------------------+
#property indicator_buffers 2
#property indicator_plots 1

// main line properties
#property indicator_color1 clrRed
#property indicator_label1 "v6"
#property indicator_style1 STYLE_SOLID
#property indicator_type1 DRAW_LINE
#property indicator_width1 1

//+------------------------------------------------------------------+
//|inputs                                                            |
//+------------------------------------------------------------------+

input int                  inpMAPeriod          =  50;               // Period
input ENUM_MA_METHOD       inpMAMethod          =  MODE_EMA;         // Method
input ENUM_APPLIED_PRICE   inpAppliedPrice      =  PRICE_CLOSE;      // Applied Price
input ENUM_TIMEFRAMES      inpTimeFrame         =  PERIOD_H4;   // Timeframe

//+------------------------------------------------------------------+
//| buffers and handles                                              |
//+------------------------------------------------------------------+
//--- Variables
int            max_lookback               =  inpMAPeriod + 1;
// indicator data buffers
double   buffer[];
double   values[];

//handles
int      handle;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0, buffer, INDICATOR_DATA);

   ArraySetAsSeries(buffer, true);
   ArraySetAsSeries(values, true);

   handle    =  iMA(Symbol(), inpTimeFrame, inpMAPeriod, 0, inpMAMethod, inpAppliedPrice);

   if(handle == INVALID_HANDLE)
     {
      printf("Failed to create Indicator handles");
      return(INIT_FAILED);
     }
   printf("handles created successfully");


   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {


//--- array series setting
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(tick_volume, true);
   ArraySetAsSeries(volume, true);
   ArraySetAsSeries(spread, true);

   int limit = prev_calculated - 1;
   if(prev_calculated == 0)
      limit = 0;

//for loop
   for(int i = limit - 1; i >= 0; i--)
     {

      int i_bar_shift = iBarShift(Symbol(), inpTimeFrame, time[i], false);
      datetime i_time = iTime(Symbol(), inpTimeFrame, i_bar_shift);

      double arr_ma[1];

      int copy_buffer = CopyBuffer(handle, 0, i_time, 1, arr_ma);

      buffer[i] = arr_ma[0];

      
      Comment("CB-MAv5. Timeframe: " + (string)inpTimeFrame + " Lookback: " + (string)inpMAPeriod);


     }

   return(rates_total);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(handle);
   Comment("");
   Print("CB-MAv5 Removed");
  }
//+------------------------------------------------------------------+
