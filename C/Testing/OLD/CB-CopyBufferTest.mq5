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
#property indicator_label1  "buffer"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1


input    ENUM_TIMEFRAMES      TimeFrame    =  PERIOD_H4;
input    int                  maPeriod     =  10;
input    int                  maShift      =  0;
input    ENUM_MA_METHOD       maMethod     =  MODE_EMA;
input    ENUM_APPLIED_PRICE   maAppliedPrice =  PRICE_CLOSE;


//--- indicator buffers
double         buffer[], values;

int handle;
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
   handle = iMA(Symbol(), TimeFrame, maPeriod, maShift, maMethod, maAppliedPrice);

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



    if(BarsCalculated(handle)<10)
      return(0);
//---
   double Buffer[];
   printf("Total copied = %d",CopyBuffer(handle,0,0,10,Buffer));
   
//--- return value of prev_calculated for next call

   return(rates_total);
  }
//+------------------------------------------------------------------+




//+------------------------------------------------------------------+
//|resources                                                         |
//+------------------------------------------------------------------+
//https://www.mql5.com/en/forum/93287?utm_source=pocket_saves