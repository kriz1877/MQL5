//+------------------------------------------------------------------+
//|                                                 CB-OrcahrdMA.mq5 |
//|                                                   Chris Bakowski |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Chris Bakowski"
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
#property indicator_label1 "v4"
#property indicator_style1 STYLE_SOLID
#property indicator_type1 DRAW_LINE
#property indicator_width1 1

//+------------------------------------------------------------------+
//|inputs                                                            |
//+------------------------------------------------------------------+

input int                  inpMAPeriod          =  50;               // Period
input ENUM_MA_METHOD       inpMAMethod          =  MODE_EMA;         // Method
input ENUM_APPLIED_PRICE   inpAppliedPrice      =  PRICE_CLOSE;      // Applied Price
input ENUM_TIMEFRAMES      inpTimeFrame         =  PERIOD_CURRENT;   // Timeframe

//+------------------------------------------------------------------+
//| buffers and handles                                              |
//+------------------------------------------------------------------+

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
  
  
//control statement
   int limit   =  rates_total - prev_calculated;
   
 
   if(prev_calculated > 0)
      limit++;


// copy buffers
   if(CopyBuffer(handle, 0, 0, limit, values) < limit)
      return(0);


//for loop
   for(int i = limit - 1; i >= 0; i--)
     {
     
    
      buffer[i]   =  values[i];


     }

   return(rates_total);
  }
//+------------------------------------------------------------------+





//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(handle);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
