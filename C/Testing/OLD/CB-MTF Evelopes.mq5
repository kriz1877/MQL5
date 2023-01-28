//+------------------------------------------------------------------+
//|                                                         TEST.mq5 |
//|                                                   Chris Bakowski |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Chris Bakowski"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window

#property indicator_buffers 4
#property indicator_plots 4

#property indicator_color1 clrRed
#property indicator_label1 "Upper"
#property indicator_style1 STYLE_SOLID
#property indicator_type1 DRAW_LINE
#property indicator_width1 1

#property indicator_color2 clrRed
#property indicator_label2 "Lower"
#property indicator_style2 STYLE_SOLID
#property indicator_type2 DRAW_LINE
#property indicator_width2 1

double UpperBuffer[], LowerBuffer[];
int envelopesHandle;
double Upper[1];
double Lower[1];

input    ENUM_TIMEFRAMES      TimeFrame               =  PERIOD_H4;
input    int                  ENVELOPES_ma_period     =  10;
input    int                  ENVELOPES_ma_shift      =  0;
input    ENUM_MA_METHOD       ENVELOPES_ma_method     =  MODE_EMA;
input    ENUM_APPLIED_PRICE   ENVELOPES_applied_price =  PRICE_CLOSE;
input    double               ENVELOPES_deviation     =  1;

///+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0, UpperBuffer, INDICATOR_DATA);
   SetIndexBuffer(1, LowerBuffer, INDICATOR_DATA);

   if((envelopesHandle = iEnvelopes(_Symbol, TimeFrame, ENVELOPES_ma_period,
                                    ENVELOPES_ma_shift, ENVELOPES_ma_method, ENVELOPES_applied_price, ENVELOPES_deviation)) == INVALID_HANDLE)
      return(INIT_FAILED);
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
   int begin = (prev_calculated > rates_total || prev_calculated <= 0) ? 0 : prev_calculated - 1, shift = iBarShift(_Symbol, TimeFrame, time[rates_total - 1]);
//---
   if(BarsCalculated(envelopesHandle) < shift)
      return(0);
//---
   for(int i = begin; i < rates_total && !_StopFlag; i++)
     {
      shift = iBarShift(_Symbol, TimeFrame, time[i]);
      if(CopyBuffer(envelopesHandle, 0, shift, 1, Upper) != -1)
         UpperBuffer[i] = Upper[0];
      if(CopyBuffer(envelopesHandle, 1, shift, 1, Lower) != -1)
         LowerBuffer[i] = Lower[0];
     }
//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
