//+------------------------------------------------------------------+
//|                                            CB-Moving Average.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   1
//--- plot MA
#property indicator_label1  "Moving Average"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1


//--- inputs
input ENUM_TIMEFRAMES      InpTimeframe      =  PERIOD_H1;     //Higher Timeframe
input int                  InpMAPeriod       =  24;            //MA Period
input ENUM_MA_METHOD       InpMethod         =  MODE_EMA;      //MA Method
input ENUM_APPLIED_PRICE   InpAppliedPrice   =  PRICE_CLOSE;   //MA Application



//--- buffers and handles
double         BufferMA[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {

   if(InpTimeframe<Period())
     {
      printf("You must sleect a timeframe higher than the current chart");
      return(INIT_PARAMETERS_INCORRECT);
     }

   SetIndexBuffer(0,BufferMA);

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

//--- set arrays as series
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

   int limit = rates_total-prev_calculated;

//+------------------------------------------------------------------+
//| Download Missing History                                         |
//+------------------------------------------------------------------+

   static int  waitCount = 10;
   if(prev_calculated==0)
     {
      if(waitCount>0)
        {
         datetime t     =  iTime(Symbol(),InpTimeframe,0);
         int      err   =  GetLastError();

         if(t==0)
           {
            waitCount--;
            printf("Waiting for data");
            return(prev_calculated);
           }
         printf("Data is now availble");
        }
      else
        {
         printf("Can't wati any longer for data");
        }
     }



   /* if(prev_calculated>0)
       limit++;*/

   if(prev_calculated>0)
     {
      if(limit<int(InpTimeframe/Period()))
         limit = PeriodSeconds(InpTimeframe)/PeriodSeconds(Period());
      if(limit>ArraySize(time))
         limit = ArraySize(time);
     }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   for(int i=limit-1; i>=0; i--)
     {
      int mtfBar  =  iBarShift(Symbol(),InpTimeframe,time[i],false);
      
      BufferMA[i] =  iMA(Symbol(),InpTimeframe,InpMAPeriod,0,InpMethod,InpAppliedPrice);
     }


//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//|To do                                                             |
//+------------------------------------------------------------------+


// inster ia handle in to the iMA funtion  
// https://www.mql5.com/en/forum/124742


//+------------------------------------------------------------------+
//|Resources                                                         |
//+------------------------------------------------------------------+
// https://www.youtube.com/watch?v=dP4VrC_nhJA
