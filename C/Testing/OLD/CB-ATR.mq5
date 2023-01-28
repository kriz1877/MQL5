//+------------------------------------------------------------------+
//|                                                       CB-ATR.mq5 |
//|                                                   Chris Bakowski |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Chris Bakowski"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window

//+------------------------------------------------------------------+
//| indicator properties                                             |
//+------------------------------------------------------------------+
#property indicator_buffers 3
#property indicator_plots 3 

// main line properties
#property indicator_color1 clrGreen
#property indicator_label1 "Main"
#property indicator_style1 STYLE_SOLID
#property indicator_type1 DRAW_LINE
#property indicator_width1 3

// upper line properties
#property indicator_color2 clrWhite
#property indicator_label2 "Upper"
#property indicator_style2 STYLE_DOT
#property indicator_type1 DRAW_LINE
#property indicator_width2 3

// lower line properties
#property indicator_color3 clrYellow
#property indicator_label3 "Lower"
#property indicator_style3 STYLE_DOT
#property indicator_type1 DRAW_LINE
#property indicator_width3 3

//+------------------------------------------------------------------+
//|inputs                                                            |
//+------------------------------------------------------------------+

// moving average 
input int                  inpMABars         =  10;            // Moving Average Bars
input ENUM_MA_METHOD       inpMAMethod       =  MODE_SMA;      // Moving Average Method
input ENUM_APPLIED_PRICE   inpMAAppliedPrice =  PRICE_CLOSE;   // Moving Average Applied Price

// atr 
input int                  inpARTBars        =  10;            // ATR Bars
input double               inpATRFactor      =  3.0;           // ATR Channel Factor

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping


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



//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
