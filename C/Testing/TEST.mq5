//+------------------------------------------------------------------+
//|                                                         TEST.mq5 |
//|                                                   Chris Bakowski |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Chris Bakowski"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window

#property indicator_buffers 3
#property indicator_plots 3

#property indicator_color1 clrRed
#property indicator_label1 "FastMA"
#property indicator_style1 STYLE_SOLID
#property indicator_type1 DRAW_LINE
#property indicator_width1 1

#property indicator_color2 clrGreen
#property indicator_label2 "SlowMA"
#property indicator_style2 STYLE_SOLID
#property indicator_type2 DRAW_LINE
#property indicator_width2 1


//inputs---

input int               fastPeriod     =  34;         // Fast Period
input ENUM_MA_METHOD    fastMethod     =  MODE_EMA;   // Fast Method

input int               slowPeriod     =  13;         // Slow Period
input ENUM_MA_METHOD    slowMethod     =  MODE_EMA;   // Slow Method

input int               signalPeriod   =  5;          // Signal Period
input ENUM_MA_METHOD    signalMethod   =  MODE_EMA;   // Signal Method

//--- buffers
double fastBuffer[], slowBuffer[], signalBuffer[];

int   maxPeriod;
int   fastHandle;
int   slowHandle;
int   signalHandle;


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {

   maxPeriod      = (int)MathMax(MathMax(fastPeriod, signalPeriod), slowPeriod);

   SetIndexBuffer(0, fastBuffer, INDICATOR_DATA);
   PlotIndexSetInteger(0, PLOT_DRAW_BEGIN, maxPeriod);



   fastHandle     =  iMA(Symbol(), Period(), fastPeriod, 0, fastMethod, PRICE_CLOSE);
   slowHandle     =  iMA(Symbol(), Period(), slowPeriod, 0, slowMethod, PRICE_CLOSE);
   signalHandle   =  iMA(Symbol(), Period(), signalPeriod, 0, signalMethod, PRICE_CLOSE);



//---
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

   if(IsStopped())
      return(0);

   if(rates_total < maxPeriod)
      return(0);

   if(BarsCalculated(fastHandle) < rates_total)
      return(0);

   if(BarsCalculated(slowHandle) < rates_total)
      return(0);

   if(BarsCalculated(signalHandle) < rates_total)
      return(0);


   int   copyBars =  0;
   if(prev_calculated > rates_total || prev_calculated <= 0)
     {
      copyBars = rates_total;
     }
   else
     {
      copyBars = rates_total - prev_calculated;
      if(prev_calculated > 0)
        {
         copyBars++;
        }
     }

   if(IsStopped())
      return(0);

   if(CopyBuffer(fastHandle, 0, 0, copyBars, fastBuffer) <= 0)
      return(0);


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
   return(rates_total);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
