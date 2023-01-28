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
#property indicator_buffers 4
#property indicator_plots 2

#property indicator_color1 clrRed
#property indicator_label1 "FastMA"
#property indicator_style1 STYLE_SOLID
#property indicator_type1 DRAW_LINE
#property indicator_width1 2

#property indicator_color2 clrGreen
#property indicator_label2 "SlowMA"
#property indicator_style2 STYLE_SOLID
#property indicator_type2 DRAW_LINE
#property indicator_width2 2

//+------------------------------------------------------------------+
//|inputs                                                            |
//+------------------------------------------------------------------+

// fast inputs
sinput   group                "Fast MA Inputs"
input    int                  inpFastMAPeriod          =  8;               // Fast Period
input    ENUM_MA_METHOD       inpFastMAMethod          =  MODE_EMA;         // Fast Method
input    ENUM_APPLIED_PRICE   inpFastAppliedPrice      =  PRICE_CLOSE;      // Fast Applied Price
input    ENUM_TIMEFRAMES      inpFastTimeFrame         =  PERIOD_D1;        // Fast Timeframe

// slow inputs
sinput   group                "Slow MA Inputs"
input    int                  inpSlowMAPeriod          =  21;               // Slow Period
input    ENUM_MA_METHOD       inpSlowMAMethod          =  MODE_EMA;         // Slow Method
input    ENUM_APPLIED_PRICE   inpSlowAppliedPrice      =  PRICE_CLOSE;      // Slow Applied Price
input    ENUM_TIMEFRAMES      inpSlowTimeFrame         =  PERIOD_D1;        // Slow Timeframe

//+------------------------------------------------------------------+
//|global variables                                                  |
//+------------------------------------------------------------------+

int            max_lookback               =  inpSlowMAPeriod + 1;
string         indicatorName              =  "CB-DoubleMA";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string         fastIndicatorArgs          = (string)inpFastMAPeriod + "Hr";
string         slowIndicatorArgs          = (string)inpSlowMAPeriod + "Hr";

//+------------------------------------------------------------------+
//|buffers and handles                                               |
//+------------------------------------------------------------------+

double   fastBuffer[];
double   slowBuffer[];

double   fastValues[];
double   slowValues[];

int      fastHandle;
int      slowHandle;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0, fastBuffer, INDICATOR_DATA);
   ArraySetAsSeries(fastBuffer, true);
   ArraySetAsSeries(fastValues, true);

   SetIndexBuffer(1, slowBuffer, INDICATOR_DATA);
   ArraySetAsSeries(slowBuffer, true);
   ArraySetAsSeries(slowValues, true);

//--- handle creation
   fastHandle    =  iMA(Symbol(), inpFastTimeFrame, inpFastMAPeriod, 0, inpFastMAMethod, inpFastAppliedPrice);
   slowHandle    =  iMA(Symbol(), inpSlowTimeFrame, inpSlowMAPeriod, 0, inpSlowMAMethod, inpSlowAppliedPrice);

   if(fastHandle == INVALID_HANDLE || slowHandle == INVALID_HANDLE)
     {
      printf("Failed to create " + indicatorName + "handles");
      return(INIT_FAILED);
     }
   printf(indicatorName + " handles created successfully");

// print label
   Comment(indicatorName + "Fast Timeframe: " + (string)inpFastTimeFrame + " Lookback: " + (string)inpFastMAPeriod + "\n" +
           indicatorName + "Slow Timeframe: " + (string)inpSlowTimeFrame + " Lookback: " + (string)inpSlowMAPeriod);


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



//+------------------------------------------------------------------+
//| control statement                                                |
//+------------------------------------------------------------------+

   int limit = prev_calculated - 1;
   if(prev_calculated == 0)
      limit = 0;


//+------------------------------------------------------------------+
//| Download Missing History                                         |
//+------------------------------------------------------------------+

   static int  waitCount = 10;
   if(prev_calculated == 0)
     {
      if(waitCount > 0)
        {
         datetime t     =  iTime(Symbol(), inpSlowTimeFrame, 0);
         int      err   =  GetLastError();

         if(t == 0)
           {
            waitCount--;
            printf("Waiting for " + indicatorName + " data");
            return(prev_calculated);
           }
         printf("Data is now available for " + indicatorName);
        }
      else
        {
         printf("Can't wait any longer for " + indicatorName + " data");
        }
     }


//+------------------------------------------------------------------+
//| Repainting Function                                              |
//+------------------------------------------------------------------+

   if(prev_calculated > 0)
     {
      if(limit < int(inpSlowTimeFrame / Period()))
         limit = PeriodSeconds(inpSlowTimeFrame) / PeriodSeconds(Period());
      if(limit > ArraySize(time))
         limit = ArraySize(time);
     }


//+------------------------------------------------------------------+
//| PrintIndicatorArgumentLabel                                      |
//+------------------------------------------------------------------+




//+------------------------------------------------------------------+
//| for loop                                                         |
//+------------------------------------------------------------------+

   for(int i = limit - 1; i >= 0; i--)
     {

      int fastBar = iBarShift(Symbol(), inpFastTimeFrame, time[i], false);
      datetime fastTime = iTime(Symbol(), inpFastTimeFrame, fastBar);

      int slowBar = iBarShift(Symbol(), inpSlowTimeFrame, time[i], false);
      datetime slowTime = iTime(Symbol(), inpSlowTimeFrame, slowBar);

      double fastArray[1];
      double slowArray[1];

      int copyFastBuffer = CopyBuffer(fastHandle, 0, fastTime, 1, fastArray);
      int copySlowBuffer = CopyBuffer(slowHandle, 0, slowTime, 1, slowArray);

      fastBuffer[i] = fastArray[0];
      slowBuffer[i] = slowArray[0];

     }

   return(rates_total);
  }//on calculate


//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(fastHandle);
   IndicatorRelease(slowHandle);
   Comment("");
   Print(indicatorName + " removed");
  }
//+------------------------------------------------------------------+




/*



datetime       timeBarOpen;

//+------------------------------------------------------------------+
//| New Bar Control                                                  |
//+------------------------------------------------------------------+
   bool newBar = false;

   if(timeBarOpen != iTime(_Symbol, PERIOD_CURRENT, 0))
     {
      newBar = true;
      timeBarOpen = iTime(_Symbol, PERIOD_CURRENT, 0);
     }

     */
//+------------------------------------------------------------------+
