//+------------------------------------------------------------------+
//|                                               CB-OnCalculate.mq5 |
//|                                                   Chris Bakowski |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Chris Bakowski"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_plots   1
//--- plot Label1
#property indicator_label1  "Label1"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
//--- input parameters
input int      Input1;
//--- indicator buffers
double         Label1Buffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0, Label1Buffer, INDICATOR_DATA);

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
//---

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

   for(int i = limit - 1; i >= 0; i--)
     {
      Print("prev_calcualted is: " + (string)prev_calculated + " | rates_total is: " + (string)rates_total + " | limit is: " + (string)limit + " | i is: " + (string)i + " | time is: " + (string)time[i]);
     }


   return(rates_total);
  }
//+------------------------------------------------------------------+




//+------------------------------------------------------------------+
//| todo                                                             |
//+------------------------------------------------------------------+

//test out old loop from v12
//watch orchard forex i- video
// fix v12








//+------------------------------------------------------------------+
//| hold                                                             |
//+------------------------------------------------------------------+

/*
 if(prev_calculated == 0)
         limit = rates_total - maxLookback;
      else
         limit = rates_total - prev_calculated + startCount;








         */
//+------------------------------------------------------------------+
