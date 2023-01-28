//+------------------------------------------------------------------+
//|                                                      ChatGPT.mq5 |
//|                                  Copyright 2023, MetaQuotes Ltd. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2023, MetaQuotes Ltd."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window

#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue

input int InpPeriod=14;
input ENUM_TIMEFRAMES InpTimeFrame=PERIOD_H1;

double EMA_Buffer[];
double Price_Buffer[];

int OnInit()
{
    //--- indicator buffers mapping
    SetIndexBuffer(0,EMA_Buffer);
    SetIndexBuffer(1,Price_Buffer);
    //---
    return(INIT_SUCCEEDED);
}

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
    //--- check for data availability
    if(rates_total<=InpPeriod) return(0);
    
    //--- check for the first call
    
    if(prev_calculated==0)
    {
        ArrayCopySeries(time,InpTimeFrame,0,rates_total-1,Price_Buffer);
    }
    else
    {
        ArrayCopySeries(time,InpTimeFrame,prev_calculated-1,rates_total-1,Price_Buffer);
    }
    ArraySetAsSeries(Price_Buffer,true);
    //--- calculate EMA
    int limit=rates_total-prev_calculated;
    for(int i=0; i<limit; i++)
    {
        EMA_Buffer[i]=iMAOnArray(Price_Buffer,0,InpPeriod,0,MODE_EMA,i);
    }
    //---
    return(rates_total);
}
