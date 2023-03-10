//+------------------------------------------------------------------+
//|                                   MA Other TimeFrame Correct.mq5 |
//|                              Copyright © 2021, Vladimir Karputov |
//|                     https://www.mql5.com/ru/market/product/43516 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2021, Vladimir Karputov"
#property link      "https://www.mql5.com/ru/market/product/43516"
#property version   "1.001"
#include <CustomFunctions.mqh>

//+------------------------------------------------------------------+
//| indicator properties                                             |
//+------------------------------------------------------------------+


#property indicator_chart_window
#property indicator_buffers   10
#property indicator_plots     7

#property indicator_label1  "Daily Fast MA"
#property indicator_type1   DRAW_SECTION
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

#property indicator_label2  "Daily Slow MA"
#property indicator_type2   DRAW_SECTION
#property indicator_color2  clrGreen
#property indicator_style2  STYLE_SOLID
#property indicator_width2  2

#property indicator_label3  "Hourly Fast MA"
#property indicator_type3   DRAW_SECTION
#property indicator_color3  clrRed
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1

#property indicator_label4  "Hourly Slow MA"
#property indicator_type4   DRAW_SECTION
#property indicator_color4  clrGreen
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1

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
//|globals variables                                                 |
//+------------------------------------------------------------------+

ENUM_MA_METHOD          maMethod             = MODE_SMA;
ENUM_APPLIED_PRICE      maAppliedTo          = PRICE_CLOSE;
bool                    m_init_error         = false;
string                  indicatorName        =  "CB-SamCo v20";
int                     gridSpace            = 50;
color                   lineColor            = clrPurple;
ENUM_LINE_STYLE         lineStyle            = STYLE_SOLID;


bool                    buyCandle, sellCandle;
color                   highColor, lowColor, buyCandleColor, sellCandleColor;

// higher
ENUM_TIMEFRAMES   higherTimeframe            = PERIOD_D1;
int               higherFastPeriod           = 8;
int               higherFastShift            = 0;
datetime          higherFastPrevBars         = 0;
datetime          higherFastPrevBars_other   = 0;
int               higherFastMAHandle         = INVALID_HANDLE;

int               higherSlowPeriod           = 21;
int               higherSlowShift            = 0;
datetime          higherSlowPrevBars         = 0;
datetime          higherSlowPrevBars_other   = 0;
int               higherSlowMAHandle         = INVALID_HANDLE;

ENUM_TIMEFRAMES   lowerTimeframe            = PERIOD_H1;
int               lowerFastPeriod           = 50;
int               lowerFastShift            = 0;
datetime          lowerFastPrevBars         = 0;
datetime          lowerFastPrevBars_other   = 0;
int               lowerFastMAHandle         = INVALID_HANDLE;

int               lowerSlowPeriod           = 200;
int               lowerSlowShift            = 0;
datetime          lowerSlowPrevBars         = 0;
datetime          lowerSlowPrevBars_other   = 0;
int               lowerSlowMAHandle         = INVALID_HANDLE;

int               maxLookbackPeriod          =  MathMax(MathMax(lowerSlowPeriod,lowerFastPeriod),MathMax(higherFastPeriod,higherSlowPeriod));
datetime          InpStartDate               = TimeCurrent()-(PeriodSeconds(PERIOD_D1)*maxLookbackPeriod);

//+------------------------------------------------------------------+
//|buffers and handles                                               |
//+------------------------------------------------------------------+

double   higherFastMABuffer[];
double   higherSlowMABuffer[];
double   lowerFastMABuffer[];
double   lowerSlowMABuffer[];

//daily highs & lows
double   dailyHighBuffer[], dailyLowBuffer[];

//object name buffer
string   arrowName[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {

//highlow  colours
   highColor         = showHighLows ? clrDarkOrange   : clrNONE;
   lowColor          = showHighLows ? clrDarkBlue     : clrNONE;

   buyCandleColor    = printCandles ? clrGreen        : clrNONE;
   sellCandleColor   = printCandles ? clrRed          : clrNONE;

//--- assignment of array to indicator buffer
   SetIndexBuffer(0, higherFastMABuffer, INDICATOR_DATA);
   ArraySetAsSeries(higherFastMABuffer, true);
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);

   SetIndexBuffer(1, higherSlowMABuffer, INDICATOR_DATA);
   ArraySetAsSeries(higherSlowMABuffer, true);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0.0);

   SetIndexBuffer(2, lowerFastMABuffer, INDICATOR_DATA);
   ArraySetAsSeries(lowerFastMABuffer, true);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, 0.0);

   SetIndexBuffer(3, lowerSlowMABuffer, INDICATOR_DATA);
   ArraySetAsSeries(lowerSlowMABuffer, true);
   PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, 0.0);

   SetIndexBuffer(4, dailyHighBuffer, INDICATOR_DATA);
   ArraySetAsSeries(dailyHighBuffer, true);
   PlotIndexSetInteger(4, PLOT_LINE_COLOR, highColor);
   PlotIndexSetDouble(4, PLOT_EMPTY_VALUE, 0.0);

   SetIndexBuffer(5, dailyLowBuffer, INDICATOR_DATA);
   ArraySetAsSeries(dailyLowBuffer, true);
   PlotIndexSetInteger(5, PLOT_LINE_COLOR, lowColor);
   PlotIndexSetDouble(5, PLOT_EMPTY_VALUE, 0.0);

//---
   if(higherTimeframe == PERIOD_CURRENT || higherTimeframe < Period())
     {
      string err_text = "'MA: timeframe' cannot be less or equal ('<=') of the current timeframe!";

      if(MQLInfoInteger(MQL_TESTER)) // when testing, we will only output to the log about incorrect input parameters
         Print(__FILE__, " ", __FUNCTION__, ", ERROR: ", err_text);
      else // if the Expert Advisor is run on the chart, tell the user about the error
         Alert(__FILE__, " ", __FUNCTION__, ", ERROR: ", err_text);

      m_init_error = true;
      return(INIT_SUCCEEDED);
     }

//--- create handle of the indicator iMA
   higherFastMAHandle = iMA(Symbol(), higherTimeframe, higherFastPeriod, higherFastShift, maMethod, maAppliedTo);
   higherSlowMAHandle = iMA(Symbol(), higherTimeframe, higherSlowPeriod, higherSlowShift, maMethod, maAppliedTo);
   lowerFastMAHandle = iMA(Symbol(), lowerTimeframe, lowerFastPeriod, lowerFastShift, maMethod, maAppliedTo);
   lowerSlowMAHandle = iMA(Symbol(), lowerTimeframe, lowerSlowPeriod, lowerSlowShift, maMethod, maAppliedTo);


//--- if the handle is not created
   if(higherFastMAHandle == INVALID_HANDLE || higherSlowMAHandle == INVALID_HANDLE || lowerFastMAHandle == INVALID_HANDLE || lowerSlowMAHandle == INVALID_HANDLE)
     {
      printf("Failed to create " + indicatorName + "handles");
      return(INIT_FAILED);
     }
   printf(indicatorName + " handles created successfully");


//+------------------------------------------------------------------+
//| CheckLoadHistory()                                               |
//+------------------------------------------------------------------+

   Print("Start load", Symbol() + "," + GetPeriodName(PERIOD_D1), "from", InpStartDate);
//---
   int res = CheckLoadHistory(Symbol(), PERIOD_D1, InpStartDate);
   switch(res)
     {
      case -1 :
         Print("Unknown symbol ", Symbol());
         break;
      case -2 :
         Print("Requested bars more than max bars in chart");
         break;
      case -3 :
         Print("Program was stopped");
         break;
      case -4 :
         Print("Indicator shouldn't load its own data");
         break;
      case -5 :
         Print("Load failed");
         break;
      case  0 :
         Print("Loaded OK");
         break;
      case  1 :
         Print("Loaded previously");
         break;
      case  2 :
         Print("Loaded previously and built");
         break;
      default :
         Print("Unknown result");
     }
//---
   datetime first_date;
   SeriesInfoInteger(Symbol(), PERIOD_D1, SERIES_FIRSTDATE, first_date);
   int bars = Bars(Symbol(), PERIOD_D1);
   Print("First date ", first_date, " - ", bars, " bars");


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


//--- array series setting
   ArraySetAsSeries(time, true);
   ArraySetAsSeries(open, true);
   ArraySetAsSeries(high, true);
   ArraySetAsSeries(low, true);
   ArraySetAsSeries(close, true);
   ArraySetAsSeries(tick_volume, true);
   ArraySetAsSeries(volume, true);
   ArraySetAsSeries(spread, true);

   /*
   //+------------------------------------------------------------------+
   //| rounds                                                           |
   //+------------------------------------------------------------------+

   //int      counted_bars = prev_calculated;
      double   k = 0;
      double   HighPrice = 0;
      double   LowPrice = 0;
      int      GridS = 0;
      int      SL = 0;
      int      digits     = Digits();
      double   point      = Point();
      double   PointRatio = MathPow(10, MathMod(digits, 2));
      double   Divisor = 0.1 / point / PointRatio;


      HighPrice   = MathRound(iHigh(Symbol(), PERIOD_CURRENT, (iHighest(Symbol(), PERIOD_CURRENT, MODE_HIGH, (rates_total - 2), 2))) * Divisor);
      LowPrice    = MathRound(iLow(Symbol(), PERIOD_CURRENT, (iLowest(Symbol(), PERIOD_CURRENT, MODE_LOW, (rates_total - 1), 2))) * Divisor);

      GridS       = gridSpace / 10;

      for(k = LowPrice; k <= HighPrice; k++)
        {
         if(MathMod(k, GridS) == 0)
           {
            if(ObjectFind(0, "Grid" + (string)k) != 0)
              {
               ObjectCreate(0, "Grid" + (string)k, OBJ_HLINE, 0, time[1], k / Divisor);
               ObjectSetInteger(0, "Grid" + (string)k, OBJPROP_STYLE, lineStyle);
               ObjectSetInteger(0, "Grid" + (string)k, OBJPROP_COLOR, lineColor);
              }
           }
        }

   */


//+------------------------------------------------------------------+
//| control statement                                                |
//+------------------------------------------------------------------+

   if(m_init_error)
      return(0);

//--- main loop
   int limit = prev_calculated - 2;
   if(prev_calculated == 0)
      limit = 0;


//+------------------------------------------------------------------+
//| Download Missing History                                         |
//+------------------------------------------------------------------+

   static int  waitCount = 20;
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
//| for loops                                                         |
//+------------------------------------------------------------------+


   for(int i = limit; i < rates_total; i++)
     {

      //reset signal bars
      buyCandle   = false;
      sellCandle  =  false;


      //+------------------------------------------------------------------+
      //|moving averages                                                   |
      //+------------------------------------------------------------------+



      //daily fast
      double higherFastPriceOther;
      datetime higherFastTimeOther;

      if(!GetPriceOther(time[i], higherFastPriceOther, higherFastTimeOther, higherTimeframe, higherFastMAHandle))
        {
         higherFastMABuffer[i]         = 0.0;
         higherFastPrevBars_other      = 0;
         return(0);
        }

      higherFastMABuffer[i]            = higherFastPriceOther;
      higherFastPrevBars_other         = higherFastTimeOther;


      //daily fast
      double higherSlowPriceOther;
      datetime higherSlowTimeOther;
      if(!GetPriceOther(time[i], higherSlowPriceOther, higherSlowTimeOther, higherTimeframe, higherSlowMAHandle))
        {
         higherSlowMABuffer[i]         = 0.0;
         higherSlowPrevBars_other      = 0;
         return(0);
        }
      higherSlowMABuffer[i]            = higherSlowPriceOther;
      higherSlowPrevBars_other         = higherSlowTimeOther;



      //hourly fast
      double lowerFastPriceOther;
      datetime lowerFastTimeOther;
      if(!GetPriceOther(time[i], lowerFastPriceOther, lowerFastTimeOther, lowerTimeframe, lowerFastMAHandle))
        {
         lowerFastMABuffer[i]         = 0.0;
         lowerFastPrevBars_other      = 0;
         return(0);
        }
      lowerFastMABuffer[i]            = lowerFastPriceOther;
      lowerFastPrevBars_other         = lowerFastTimeOther;


      //daily fast
      double lowerSlowPriceOther;
      datetime lowerSlowTimeOther;
      if(!GetPriceOther(time[i], lowerSlowPriceOther, lowerSlowTimeOther, lowerTimeframe, lowerSlowMAHandle))
        {
         lowerSlowMABuffer[i]         = 0.0;
         lowerSlowPrevBars_other      = 0;
         return(0);
        }
      lowerSlowMABuffer[i]            = lowerSlowPriceOther;
      lowerSlowPrevBars_other         = lowerSlowTimeOther;


      for(int j = i; j >= 0; j--)
        {
         //daily fast
         if(!GetPriceOther(time[j], higherFastPriceOther, higherFastTimeOther, higherTimeframe, higherFastMAHandle))
           {
            higherFastMABuffer[j]      = 0.0;
            higherFastPrevBars_other   = 0;
            return(0);
           }
         if(higherFastPrevBars_other != higherFastTimeOther)
            break;
         higherFastMABuffer[j] = higherFastPriceOther;


         //daily slow
         if(!GetPriceOther(time[j], higherSlowPriceOther, higherSlowTimeOther, higherTimeframe, higherSlowMAHandle))
           {
            higherSlowMABuffer[j]      = 0.0;
            higherSlowPrevBars_other   = 0;
            return(0);
           }
         if(higherSlowPrevBars_other != higherSlowTimeOther)
            break;
         higherSlowMABuffer[j] = higherSlowPriceOther;



         //hourly fast
         if(!GetPriceOther(time[j], lowerFastPriceOther, lowerFastTimeOther, lowerTimeframe, lowerFastMAHandle))
           {
            lowerFastMABuffer[j]      = 0.0;
            lowerFastPrevBars_other   = 0;
            return(0);
           }
         if(lowerFastPrevBars_other != lowerFastTimeOther)
            break;
         lowerFastMABuffer[j] = lowerFastPriceOther;


         //hourly slow
         if(!GetPriceOther(time[j], lowerSlowPriceOther, lowerSlowTimeOther, lowerTimeframe, lowerSlowMAHandle))
           {
            lowerSlowMABuffer[j]      = 0.0;
            lowerSlowPrevBars_other   = 0;
            return(0);
           }
         if(lowerSlowPrevBars_other != lowerSlowTimeOther)
            break;
         lowerSlowMABuffer[j] = lowerSlowPriceOther;
        }

      bool     EMA_Bull = (higherFastMABuffer[i]   >  higherSlowMABuffer[i]) && (lowerFastMABuffer[i]  >  lowerSlowMABuffer[i]);
      bool     EMA_Bear = (higherFastMABuffer[i]   <  higherSlowMABuffer[i]) && (lowerFastMABuffer[i]  <  lowerSlowMABuffer[i]);


      //+------------------------------------------------------------------+
      //|highs & lows                                                      |
      //+------------------------------------------------------------------+

      //daily
      int dailyBar = iBarShift(_Symbol, PERIOD_D1, time[i], false);
      int hourlyBar = iBarShift(_Symbol, PERIOD_H1, time[i], false);

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



     }
//--- return the prev_calculated value for the next call
   return(rates_total);
  }
//+------------------------------------------------------------------+
//| Indicator deinitialization function                              |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(higherFastMAHandle != INVALID_HANDLE)
      IndicatorRelease(higherFastMAHandle);

   if(higherSlowMAHandle != INVALID_HANDLE)
      IndicatorRelease(higherSlowMAHandle);

   if(lowerFastMAHandle != INVALID_HANDLE)
      IndicatorRelease(lowerFastMAHandle);

   if(lowerSlowMAHandle != INVALID_HANDLE)
      IndicatorRelease(lowerSlowMAHandle);

   IndicatorRelease(higherFastMAHandle);
   IndicatorRelease(higherSlowMAHandle);
   IndicatorRelease(lowerFastMAHandle);
   IndicatorRelease(lowerSlowMAHandle);
   Comment("");
   Print(indicatorName + " removed");

   int createdArrows = ArraySize(arrowName);

   for(int i = createdArrows - 1; i >= 0; i--)
     {
      if(ObjectFind(0, arrowName[i]) >= 0)
         ArrowDelete(0, arrowName[i]);
     }

   /*//fix this infinite loop

         ObjectsDeleteAll(0, "Grid");
         double k             = 0;
         double HighPrice     = 0;
         double LowPrice      = 0;

         double Divisor       = 0.1 / Point();

         for(k = LowPrice; k <= HighPrice; shift++)
           {
            ObjectDelete(0, "Grid" + (string)k);
           }
        */
  }




//+------------------------------------------------------------------+
//| GetPriceOther()                                                  |
//+------------------------------------------------------------------+
bool GetPriceOther(const datetime time_current, double &price, datetime &time, ENUM_TIMEFRAMES timeframe, int handle)
  {
   int i_bar_shift_other = iBarShift(Symbol(), timeframe, time_current, false);
   if(i_bar_shift_other < 0)
     {
      return(false);
     }
   else
     {
      datetime i_TimeOther = iTime(Symbol(), timeframe, i_bar_shift_other);
      if(i_TimeOther == D'1970.01.01 00:00')
        {
         return(false);
        }
      else
        {
         if(BarsCalculated(handle) <= 0)
            return(false);
         double arr_ma[];
         int copy_buffer = CopyBuffer(handle, 0, i_TimeOther, 1, arr_ma);
         if(CopyBuffer(handle, 0, i_TimeOther, 1, arr_ma) != 1)
           {
            return(false) ;
           }
         else
           {
            price = arr_ma[0];
            time = i_TimeOther;
           }
        }
     }
//---
   return(true);
  }
//+------------------------------------------------------------------+




//+------------------------------------------------------------------+
//|CandleDrawArrow()                                                       |
//+------------------------------------------------------------------+
void CandleDrawArrow(const double price1, const datetime time1, const color colour, const string M_type, const uchar code = 159, const ENUM_ARROW_ANCHOR anchor = ANCHOR_BOTTOM)
  {
//--- arrow name
   string   name  = StringFormat("%s %s time: %s", M_type, DoubleToString(price1), TimeToString(time1));
//---
   if(ObjectFind(0, name) < 0)
     {
      if(CandleArrowCreate(0, name, 0, time1, price1, code, anchor, colour))
        {
         int size  =  ArraySize(arrowName);
         ArrayResize(arrowName, size + 1, 1000);
         arrowName[size]  =  name;
        }
     }
   else
      ArrowMove(0, name, time1, price1);
  }





//+------------------------------------------------------------------+
//| CandleArrowCreate()                                              |
//+------------------------------------------------------------------+
bool CandleArrowCreate(const long              chart_ID = 0,         // chart's ID
                       const string            name = "Arrow",       // arrow name
                       const int               sub_window = 0,       // subwindow index
                       datetime                time = 0,             // anchor point time
                       double                  price = 0,            // anchor point price
                       const uchar             arrow_code = 252,     // arrow code
                       const ENUM_ARROW_ANCHOR anchor = ANCHOR_BOTTOM, // anchor point position
                       const color             clr = clrRed,         // arrow color
                       const ENUM_LINE_STYLE   style = STYLE_SOLID,  // border line style
                       const int               width = 1,            // arrow size
                       const bool              back = false,         // in the background
                       const bool              selection = false,     // highlight to move
                       const bool              hidden = true,        // hidden in the object list
                       const long              z_order = 0)          // priority for mouse click
  {
//--- set anchor point coordinates if they are not set
   ChangeArrowEmptyPoint(time, price);
//--- reset the error value
   ResetLastError();
//--- create an arrow
   if(!ObjectCreate(chart_ID, name, OBJ_ARROW, sub_window, time, price))
     {
      Print(__FUNCTION__,
            ": failed to create an arrow! Error code = ", GetLastError());
      return(false);
     }
//--- set the arrow code
   ObjectSetInteger(chart_ID, name, OBJPROP_ARROWCODE, arrow_code);
//--- set anchor type
   ObjectSetInteger(chart_ID, name, OBJPROP_ANCHOR, anchor);
//--- set the arrow color
   ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
//--- set the border line style
   ObjectSetInteger(chart_ID, name, OBJPROP_STYLE, style);
//--- set the arrow's size
   ObjectSetInteger(chart_ID, name, OBJPROP_WIDTH, width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
//--- enable (true) or disable (false) the mode of moving the arrow by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
//--- successful execution
   return(true);
  }




//+------------------------------------------------------------------+
//|SignalDrawArrow()                                                 |
//+------------------------------------------------------------------+
void SignalDrawArrow(const double price1, const datetime time1, const color colour, const string M_type, const uchar code = 159, const ENUM_ARROW_ANCHOR anchor = ANCHOR_BOTTOM)
  {
//--- arrow name
   string   name  = StringFormat("%s %s time: %s", M_type, DoubleToString(price1), TimeToString(time1));
//---
   if(ObjectFind(0, name) < 0)
     {
      if(SignalArrowCreate(0, name, 0, time1, price1, code, anchor, colour))
        {
         int size  =  ArraySize(arrowName);
         ArrayResize(arrowName, size + 1, 1000);
         arrowName[size]  =  name;
        }
     }
   else
      ArrowMove(0, name, time1, price1);
  }







//+------------------------------------------------------------------+
//| SignalArrowCreate()                                              |
//+------------------------------------------------------------------+
bool SignalArrowCreate(const long              chart_ID = 0,         // chart's ID
                       const string            name = "Arrow",       // arrow name
                       const int               sub_window = 0,       // subwindow index
                       datetime                time = 0,             // anchor point time
                       double                  price = 0,            // anchor point price
                       const uchar             arrow_code = 252,     // arrow code
                       const ENUM_ARROW_ANCHOR anchor = ANCHOR_BOTTOM, // anchor point position
                       const color             clr = clrRed,         // arrow color
                       const ENUM_LINE_STYLE   style = STYLE_SOLID,  // border line style
                       const int               width = 3,            // arrow size
                       const bool              back = false,         // in the background
                       const bool              selection = false,     // highlight to move
                       const bool              hidden = true,        // hidden in the object list
                       const long              z_order = 0)          // priority for mouse click
  {
//--- set anchor point coordinates if they are not set
   ChangeArrowEmptyPoint(time, price);
//--- reset the error value
   ResetLastError();
//--- create an arrow
   if(!ObjectCreate(chart_ID, name, OBJ_ARROW, sub_window, time, price))
     {
      Print(__FUNCTION__,
            ": failed to create an arrow! Error code = ", GetLastError());
      return(false);
     }
//--- set the arrow code
   ObjectSetInteger(chart_ID, name, OBJPROP_ARROWCODE, arrow_code);
//--- set anchor type
   ObjectSetInteger(chart_ID, name, OBJPROP_ANCHOR, anchor);
//--- set the arrow color
   ObjectSetInteger(chart_ID, name, OBJPROP_COLOR, clr);
//--- set the border line style
   ObjectSetInteger(chart_ID, name, OBJPROP_STYLE, style);
//--- set the arrow's size
   ObjectSetInteger(chart_ID, name, OBJPROP_WIDTH, width);
//--- display in the foreground (false) or background (true)
   ObjectSetInteger(chart_ID, name, OBJPROP_BACK, back);
//--- enable (true) or disable (false) the mode of moving the arrow by mouse
//--- when creating a graphical object using ObjectCreate function, the object cannot be
//--- highlighted and moved by default. Inside this method, selection parameter
//--- is true by default making it possible to highlight and move the object
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTABLE, selection);
   ObjectSetInteger(chart_ID, name, OBJPROP_SELECTED, selection);
//--- hide (true) or display (false) graphical object name in the object list
   ObjectSetInteger(chart_ID, name, OBJPROP_HIDDEN, hidden);
//--- set the priority for receiving the event of a mouse click in the chart
   ObjectSetInteger(chart_ID, name, OBJPROP_ZORDER, z_order);
//--- successful execution
   return(true);
  }




//+------------------------------------------------------------------+
//| Move the anchor point                                            |
//+------------------------------------------------------------------+
bool ArrowMove(const long   chart_ID = 0, // chart's ID
               const string name = "Arrow", // object name
               datetime     time = 0,     // anchor point time coordinate
               double       price = 0)    // anchor point price coordinate
  {
//--- if point position is not set, move it to the current bar having Bid price
   if(!time)
      time = TimeCurrent();
   if(!price)
      price = SymbolInfoDouble(Symbol(), SYMBOL_BID);
//--- reset the error value
   ResetLastError();
//--- move the anchor point
   if(!ObjectMove(chart_ID, name, 0, time, price))
     {
      Print(__FUNCTION__,
            ": failed to move the anchor point! Error code = ", GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }





//+------------------------------------------------------------------+
//| Change the arrow code                                            |
//+------------------------------------------------------------------+
bool ArrowCodeChange(const long   chart_ID = 0, // chart's ID
                     const string name = "Arrow", // object name
                     const uchar  code = 252)   // arrow code
  {
//--- reset the error value
   ResetLastError();
//--- change the arrow code
   if(!ObjectSetInteger(chart_ID, name, OBJPROP_ARROWCODE, code))
     {
      Print(__FUNCTION__,
            ": failed to change the arrow code! Error code = ", GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }




//+------------------------------------------------------------------+
//| Change anchor type                                               |
//+------------------------------------------------------------------+
bool ArrowAnchorChange(const long              chart_ID = 0,      // chart's ID
                       const string            name = "Arrow",    // object name
                       const ENUM_ARROW_ANCHOR anchor = ANCHOR_TOP) // anchor type
  {
//--- reset the error value
   ResetLastError();
//--- change anchor type
   if(!ObjectSetInteger(chart_ID, name, OBJPROP_ANCHOR, anchor))
     {
      Print(__FUNCTION__,
            ": failed to change anchor type! Error code = ", GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }




//+------------------------------------------------------------------+
//| Delete an arrow                                                  |
//+------------------------------------------------------------------+
bool ArrowDelete(const long   chart_ID = 0, // chart's ID
                 const string name = "Arrow") // arrow name
  {
//--- reset the error value
   ResetLastError();
//--- delete an arrow
   if(!ObjectDelete(chart_ID, name))
     {
      Print(__FUNCTION__,
            ": failed to delete an arrow! Error code = ", GetLastError());
      return(false);
     }
//--- successful execution
   return(true);
  }




//+------------------------------------------------------------------+
//| Check anchor point values and set default values                 |
//| for empty ones                                                   |
//+------------------------------------------------------------------+
void ChangeArrowEmptyPoint(datetime & time, double & price)
  {
//--- if the point's time is not set, it will be on the current bar
   if(!time)
      time = TimeCurrent();
//--- if the point's price is not set, it will have Bid value
   if(!price)
      price = SymbolInfoDouble(Symbol(), SYMBOL_BID);
  }
//+------------------------------------------------------------------+



//+------------------------------------------------------------------+
