//+------------------------------------------------------------------+
//|                                                         TEST.mq5 |
//|                                                   Chris Bakowski |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Chris Bakowski"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#include <CustomFunctions.mqh>


//+------------------------------------------------------------------+
//| indicator properties                                             |
//+------------------------------------------------------------------+

#property indicator_buffers 10
#property indicator_plots 7

#property indicator_color1 clrRed
#property indicator_label1 "Daily FastMA"
#property indicator_style1 STYLE_SOLID
#property indicator_type1 DRAW_LINE
#property indicator_width1 2

#property indicator_color2 clrGreen
#property indicator_label2 "Daily SlowMA"
#property indicator_style2 STYLE_SOLID
#property indicator_type2 DRAW_LINE
#property indicator_width2 2

#property indicator_color3 clrRed
#property indicator_label3 "Hourly FastMA"
#property indicator_style3 STYLE_SOLID
#property indicator_type3 DRAW_LINE
#property indicator_width3 1

#property indicator_color4 clrGreen
#property indicator_label4 "Hourly SlowMA"
#property indicator_style4 STYLE_SOLID
#property indicator_type4 DRAW_LINE
#property indicator_width4 1

#property indicator_color5 clrOrange
#property indicator_label5 "Daily High"
#property indicator_style5 STYLE_SOLID
#property indicator_type5 DRAW_LINE
#property indicator_width5 1

#property indicator_color6 clrDarkBlue
#property indicator_label6 "Daily Low"
#property indicator_style6 STYLE_SOLID
#property indicator_type6 DRAW_LINE
#property indicator_width6 1


//+------------------------------------------------------------------+
//|inputs                                                            |
//+------------------------------------------------------------------+
sinput   group        "Visualisation"
input    bool         showHighLows  =  false;    //Show High & Low of the Day on Chart?
input    bool         printCandles  =  true;     //Print all candles?


//+------------------------------------------------------------------+
//|global variables                                                  |
//+------------------------------------------------------------------+

int            max_lookback               =  PERIOD_D1 + 1;
string         indicatorName              =  "CB-SamCo v15";
color          highColor, lowColor, buyCandleColor, sellCandleColor;
int            shift                      =  10;
bool           buyCandle, sellCandle;


//+------------------------------------------------------------------+
//|buffers and handles                                               |
//+------------------------------------------------------------------+

//daily
double   dailyFastBuffer[], dailyFastValues[];
double   dailySlowBuffer[], dailySlowValues[];
int      dailyFastHandle, dailySlowHandle;

//hourly
double   hourlyFastBuffer[], hourlyFastValues[];
double   hourlySlowBuffer[], hourlySlowValues[];
int      hourlyFastHandle, hourlySlowHandle;

//daily highs & lows
double   dailyHighBuffer[], dailyLowBuffer[];

//object name buffer
string   Arrow_Name[];



///+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {

//highlow  colours
   highColor         = showHighLows ? clrDarkOrange   : clrNONE;
   lowColor          = showHighLows ? clrDarkBlue     : clrNONE;

   buyCandleColor    = printCandles ? clrGreen        : clrNONE;
   sellCandleColor   = printCandles ? clrRed          : clrNONE;


//--- indicator buffers mapping
   SetIndexBuffer(0, dailyFastBuffer, INDICATOR_DATA);
   ArraySetAsSeries(dailyFastBuffer, true);
   ArraySetAsSeries(dailyFastValues, true);

   SetIndexBuffer(1, dailySlowBuffer, INDICATOR_DATA);
   ArraySetAsSeries(dailySlowBuffer, true);
   ArraySetAsSeries(dailySlowValues, true);

   SetIndexBuffer(2, hourlyFastBuffer, INDICATOR_DATA);
   ArraySetAsSeries(hourlyFastBuffer, true);
   ArraySetAsSeries(hourlyFastValues, true);

   SetIndexBuffer(3, hourlySlowBuffer, INDICATOR_DATA);
   ArraySetAsSeries(hourlySlowBuffer, true);
   ArraySetAsSeries(hourlySlowValues, true);

   SetIndexBuffer(4, dailyHighBuffer, INDICATOR_DATA);
   ArraySetAsSeries(dailyHighBuffer, true);
   PlotIndexSetInteger(4, PLOT_LINE_COLOR, highColor);

   SetIndexBuffer(5, dailyLowBuffer, INDICATOR_DATA);
   ArraySetAsSeries(dailyLowBuffer, true);
   PlotIndexSetInteger(5, PLOT_LINE_COLOR, lowColor);


//--- handle creation
   dailyFastHandle   =   iMA(Symbol(), PERIOD_D1, 8, 0, MODE_EMA, PRICE_CLOSE);
   dailySlowHandle   =  iMA(Symbol(), PERIOD_D1, 21, 0, MODE_EMA, PRICE_CLOSE);
   hourlyFastHandle  =  iMA(Symbol(), PERIOD_H1, 50, 0, MODE_EMA, PRICE_CLOSE);
   hourlySlowHandle  =  iMA(Symbol(), PERIOD_H1, 200, 0, MODE_EMA, PRICE_CLOSE);


// error message if handles unable to be created
   if(dailyFastHandle == INVALID_HANDLE || dailySlowHandle == INVALID_HANDLE || hourlyFastHandle == INVALID_HANDLE || hourlySlowHandle == INVALID_HANDLE)
     {
      printf("Failed to create " + indicatorName + "handles");
      return(INIT_FAILED);
     }
   printf(indicatorName + " handles created successfully");

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


   int limit = (prev_calculated > rates_total || prev_calculated <= 0) ? 0 : prev_calculated - 1, dailyBar = iBarShift(_Symbol, PERIOD_D1, time[rates_total - 1]);

   if(BarsCalculated(dailyFastHandle) < dailyBar)
      return(0);

//+------------------------------------------------------------------+
//| Download Missing History                                         |
//+------------------------------------------------------------------+

   static int  waitCount = 10;
   if(prev_calculated == 0)
     {
      if(waitCount > 0)
        {
         datetime t     =  iTime(Symbol(), PERIOD_D1, 0);
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
      if(limit < PeriodSeconds(PERIOD_D1) / PeriodSeconds(Period()))
         limit = PeriodSeconds(PERIOD_D1) / PeriodSeconds(Period());
      if(limit > ArraySize(time))
         limit = ArraySize(time);
     }



//+------------------------------------------------------------------+
//| for loop                                                         |
//+------------------------------------------------------------------+

   for(int i = limit; i < rates_total && !_StopFlag; i++)
     {
      buyCandle   = false;
      sellCandle  =  false;

      //+------------------------------------------------------------------+
      //| moving averages                                                  |
      //+------------------------------------------------------------------+

      //daily
      dailyBar = iBarShift(_Symbol, PERIOD_D1, time[i], false);

      if(CopyBuffer(dailyFastHandle, 0, dailyBar, 1, dailyFastValues) != -1)
        {
         dailyFastBuffer[i] = dailyFastValues[0];
        }

      if(CopyBuffer(dailySlowHandle, 0, dailyBar, 1, dailySlowValues) != -1)
        {
         dailySlowBuffer[i] = dailySlowValues[0];
        }


      //hourly
      int hourlyBar = iBarShift(_Symbol, PERIOD_H1, time[i], false);

      if(CopyBuffer(hourlyFastHandle, 0, hourlyBar, 1, hourlyFastValues) != -1)
        {
         hourlyFastBuffer[i] = hourlyFastValues[0];
        }

      if(CopyBuffer(hourlySlowHandle, 0, hourlyBar, 1, hourlySlowValues) != -1)
        {
         hourlySlowBuffer[i] = hourlySlowValues[0];
        }

      bool     EMA_Bull = (dailyFastBuffer[i]   >  dailySlowBuffer[i]) && (hourlyFastBuffer[i]  >  hourlySlowBuffer[i]);
      bool     EMA_Bear = (dailyFastBuffer[i]   <  dailySlowBuffer[i]) && (hourlyFastBuffer[i]  <  hourlySlowBuffer[i]);



      //+------------------------------------------------------------------+
      //|highs & lows                                                      |
      //+------------------------------------------------------------------+

      //--- attached saily highs and lows to bufer
      dailyHighBuffer[i]   =  iHigh(Symbol(), PERIOD_D1, dailyBar);
      dailyLowBuffer[i]    =  iLow(Symbol(), PERIOD_D1, dailyBar);

      //--- boolean to define if it is or isnt daily high
      bool isDailyHigh     =  high[i] == dailyHighBuffer[i];
      bool isDailyLow      =  low[i]  == dailyLowBuffer[i];


      //+------------------------------------------------------------------+
      //|Market conditions                                                 |
      //+------------------------------------------------------------------+

      // check whether the past 3 candles from i are swing lows or hihgs
      bool  isSwingHigh       = IsSwingHigh(i, 10, i);
      bool  isSwingLow        = IsSwingLow(i, 10, i);


      //+------------------------------------------------------------------+
      //| Candles                                                          |
      //+------------------------------------------------------------------+

      //--- EC_Bull
      if(EC_Bull(i) && EMA_Bull && isSwingLow)
        {
         double   price    = low[i] - 10 * Point();
         datetime _time    = time[i];
         CandleDrawArrow(price, _time, buyCandleColor, "Buy", 141, ANCHOR_TOP);
         buyCandle = true;
        }


      //--- EC_Bear
      if(EC_Bear(i) && EMA_Bear && isSwingHigh)
        {
         double   price    = high[i] + 10 * Point();
         datetime _time    = time[i];
         CandleDrawArrow(price, _time, sellCandleColor, "Sell", 141, ANCHOR_BOTTOM);
         sellCandle = true;
        }


      //--- PB_Green_Bull
      if((PB_Bull_JD(i) && EMA_Bull && isSwingLow) || (PB_Bull_TV(i) && EMA_Bull && isSwingLow))
        {
         double   price    = low[i] - 10 * Point();
         datetime _time    = time[i];
         CandleDrawArrow(price, _time, buyCandleColor, "Buy", 140, ANCHOR_TOP);
         buyCandle = true;
        }

      if((PB_Bear_JD(i) && EMA_Bear && isSwingHigh) || (PB_Bear_TV(i) && EMA_Bear && isSwingHigh))
        {
         double   price    = high[i] + 10 * Point();
         datetime _time    = time[i];
         CandleDrawArrow(price, _time, sellCandleColor, "Sell", 140, ANCHOR_BOTTOM);
         sellCandle = true;
        }


      //+------------------------------------------------------------------+
      //|master signal                                                     |
      //+------------------------------------------------------------------+

      bool goLong    =  EMA_Bull && isSwingLow  && isDailyLow  && buyCandle;
      bool goShort   =  EMA_Bear && isSwingHigh && isDailyHigh && sellCandle;

      if(goLong)
        {
         double   price    = low[i] - 50 * Point();
         datetime _time    = time[i];
         SignalDrawArrow(price, _time, clrGreen, "goLong", 233, ANCHOR_TOP);
        }

      if(goShort)
        {
         double   price    = high[i] + 50 * Point();
         datetime _time    = time[i];
         SignalDrawArrow(price, _time, clrRed, "goShort", 234, ANCHOR_BOTTOM);
        }


      //+------------------------------------------------------------------+
      //| for loop                                                         |
      //+------------------------------------------------------------------+

     }

   return(rates_total);
  }
//+------------------------------------------------------------------+






//+------------------------------------------------------------------+
//|  EC_Bull                                                         |
//+------------------------------------------------------------------+
bool EC_Bull(int _index)
  {

   double close_i    =  iClose(Symbol(), PERIOD_CURRENT, _index);
   double close_i1   =  iClose(Symbol(), PERIOD_CURRENT, _index + 1);

   double open_i     =  iOpen(Symbol(), PERIOD_CURRENT, _index);
   double open_i1    =  iOpen(Symbol(), PERIOD_CURRENT, _index + 1);

   double low_i      =  iLow(Symbol(), PERIOD_CURRENT, _index);
   double low_i1     =  iLow(Symbol(), PERIOD_CURRENT, _index + 1);


   if((close_i1   <  open_i1)
      && (open_i  <= close_i1)
      && (close_i >= open_i1)
      && (low_i   <= low_i1))
     {
      return(true);
     }
   else
     {
      return(false);
     }
  }//returns true if indexed candle is a bullish engulfing


//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(dailyFastHandle);
   IndicatorRelease(dailySlowHandle);
   Comment("");
   Print(indicatorName + " removed");

   int createdArrows = ArraySize(Arrow_Name);

   for(int i = createdArrows - 1; i >= 0; i--)
     {
      if(ObjectFind(0, Arrow_Name[i]) >= 0)
         ArrowDelete(0, Arrow_Name[i]);
     }
  }
//+------------------------------------------------------------------+

