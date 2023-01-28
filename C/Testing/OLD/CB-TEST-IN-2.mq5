//+------------------------------------------------------------------+
//|                                                       SMA v2.mq5 |
//|                                  Copyright 2022, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_plots   2
//--- plot MA
#property indicator_label1  "MA"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1

#property indicator_label2  "Series"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkBlue
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1

//--- input parameters
input int                  InpPeriod   =  50;            //Period
input ENUM_MA_METHOD       InpMethod   =  MODE_SMA;      //ME Method
input ENUM_APPLIED_PRICE   InpApplyTo  =  PRICE_CLOSE;   //Applied to


//--- indicator buffers
double   Buffer[];
double   Series[];
int      ma_handle      = INVALID_HANDLE;
int   series_handle  =  INVALID_HANDLE;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {

//--- indicator buffers mapping
   SetIndexBuffer(0, Buffer, INDICATOR_DATA);
   ArraySetAsSeries(Buffer, true);
   IndicatorSetString(INDICATOR_SHORTNAME, "Buffer " + (string)InpPeriod);

//--- indicator buffers mapping
   SetIndexBuffer(1, Series, INDICATOR_DATA);
   ArraySetAsSeries(Series, true);
   IndicatorSetString(INDICATOR_SHORTNAME, "Series " + (string)InpPeriod);


//---create Indicator
   ma_handle   =  iMA(_Symbol, PERIOD_CURRENT, InpPeriod, 0, InpMethod, InpApplyTo);
   series_handle  =  iClose(_Symbol, PERIOD_CURRENT, 0);


//--- check if indicator was created
   if(ma_handle == INVALID_HANDLE)
     {
      printf("Failed to create Moving Average Indicator: [%d]", GetLastError());
      return INIT_FAILED;
     }

//--- check if series was created
   if(series_handle == INVALID_HANDLE)
     {
      printf("Failed to create Series: [%d]", GetLastError());
      return INIT_FAILED;
     }
     
     
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

//--- refresh indicator
   int limit   =  rates_total - prev_calculated;
   if(prev_calculated > 0)
      limit++;


//--- assign cerated indicator values to plotting buffer
   CopyBuffer(ma_handle, 0, 0, limit + 1, Buffer);



   for(int i = limit - 1; i >= 0; i--)
     {
CopyBuffer(series_handle, 0, 0, limit + 1, Series);

     }

//--- return value of prev_calculated for next call
   return(rates_total);
  }
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
