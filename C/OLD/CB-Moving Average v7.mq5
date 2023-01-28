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

#property indicator_color1 clrRed
#property indicator_label1 "v7"
#property indicator_style1 STYLE_SOLID
#property indicator_type1 DRAW_LINE
#property indicator_width1 1


//+------------------------------------------------------------------+
//|inputs                                                            |
//+------------------------------------------------------------------+

input int                  inpMAPeriod          =  21;               // Period
input ENUM_MA_METHOD       inpMAMethod          =  MODE_EMA;         // Method
input ENUM_APPLIED_PRICE   inpAppliedPrice      =  PRICE_CLOSE;      // Applied Price
input ENUM_TIMEFRAMES      inpTimeFrame         =  PERIOD_H4;   // Timeframe


//+------------------------------------------------------------------+
//|global variables                                                  |
//+------------------------------------------------------------------+

int            max_lookback               =  inpMAPeriod + 1;
string         indicatorName              =  "CB-MAv7";
string         indicatorArgs              = (string)inpMAPeriod + "Hr";


//+------------------------------------------------------------------+
//|buffers and handles                                               |
//+------------------------------------------------------------------+

double   buffer[];
double   values[];

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

//--- handle creation
   handle    =  iMA(Symbol(), inpTimeFrame, inpMAPeriod, 0, inpMAMethod, inpAppliedPrice);

   if(handle == INVALID_HANDLE)
     {
      printf("Failed to create " + indicatorName + "handles");
      return(INIT_FAILED);
     }
   printf(indicatorName + " handles created successfully");

// print label
   Comment(indicatorName + "Timeframe: " + (string)inpTimeFrame + " Lookback: " + (string)inpMAPeriod);


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
         datetime t     =  iTime(Symbol(), inpTimeFrame, 0);
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
      if(limit < int(inpTimeFrame / Period()))
         limit = PeriodSeconds(inpTimeFrame) / PeriodSeconds(Period());
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

      int i_bar_shift = iBarShift(Symbol(), inpTimeFrame, time[i], false);
      datetime i_time = iTime(Symbol(), inpTimeFrame, i_bar_shift);

      double arr_ma[1];
      int copy_buffer = CopyBuffer(handle, 0, i_time, 1, arr_ma);
      buffer[i] = arr_ma[0];

    
     }

   return(rates_total);
  }//on calculate


//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(handle);
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
