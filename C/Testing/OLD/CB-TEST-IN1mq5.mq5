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
#property indicator_buffers 2
#property indicator_plots 1

// main line properties
#property indicator_color1 clrDarkBlue
#property indicator_label1 "TestSeries"
#property indicator_style1 STYLE_SOLID
#property indicator_type1 DRAW_LINE
#property indicator_width1 2

//+------------------------------------------------------------------+
//|inputs                                                            |
//+------------------------------------------------------------------+

input int                  inpMABars         =  10;            // Moving Average Bars

//+------------------------------------------------------------------+
//| buffers and handles                                              |
//+------------------------------------------------------------------+

//handles
int      handleSeries;
//bufers
double   bufferMain[];
double   values[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0, bufferMain);

   ArraySetAsSeries(bufferMain, true);
   ArraySetAsSeries(values, true);

   handleSeries    =  ;

   if(handleSeries == INVALID_HANDLE)
     {
      printf("Failed to create Indicator handles");
      return(INIT_FAILED);
     }

   return(INIT_SUCCEEDED);
  }


//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                         |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(handleSeries);
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
//control statement
   int limit   =  rates_total - prev_calculated;
   if(prev_calculated > 0)
      limit++;

// copy buffers
   if(CopyBuffer(handleSeries, 0, 0, limit, values) < limit)
      return(0);


//for loop
   for(int i = limit - 1; i >= 0; i--)
     {

      bufferMain[i] = close[i];

     }

   return(rates_total);
  }
//+------------------------------------------------------------------+
