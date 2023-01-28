//+------------------------------------------------------------------+
//|                                                          CB-.mq5 |
//|                                                            Chris |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Chris"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property indicator_chart_window
#include <CustomFunctions.mqh>


//+------------------------------------------------------------------+
//| indicator properties                                             |
//+------------------------------------------------------------------+
#property indicator_buffers 13
#property indicator_plots 9

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

#property indicator_color5 clrNONE
#property indicator_label5 "Daily Signal"
#property indicator_type5 DRAW_NONE
#property indicator_width5 1

#property indicator_color6 clrNONE
#property indicator_label6 "Hourly Signal"
#property indicator_type6 DRAW_NONE
#property indicator_width6 1

#property indicator_color7 clrOrange
#property indicator_label7 "Daily High"
#property indicator_style7 STYLE_SOLID
#property indicator_type7 DRAW_LINE
#property indicator_width7 1



//+------------------------------------------------------------------+
//|inputs                                                            |
//+------------------------------------------------------------------+

// daily fast inputs
sinput   group                "Daily Fast MA Inputs"
input    int                  inpDailyFastMAPeriod          =  8;                // Daily Fast Period
input    ENUM_MA_METHOD       inpDailyFastMAMethod          =  MODE_EMA;         // Daily Fast Method
input    ENUM_APPLIED_PRICE   inpDailyFastAppliedPrice      =  PRICE_CLOSE;      // Daily Fast Applied Price
input    ENUM_TIMEFRAMES      inpDailyFastTimeFrame         =  PERIOD_D1;        // Daily Fast Timeframe

// daily slow inputs
sinput   group                "Daily Slow MA Inputs"
input    int                  inpDailySlowMAPeriod          =  21;               // Daily Slow Period
input    ENUM_MA_METHOD       inpDailySlowMAMethod          =  MODE_EMA;         // Daily Slow Method
input    ENUM_APPLIED_PRICE   inpDailySlowAppliedPrice      =  PRICE_CLOSE;      // Daily Slow Applied Price
input    ENUM_TIMEFRAMES      inpDailySlowTimeFrame         =  PERIOD_D1;        // Daily Slow Timeframe



// hourly fast inputs
sinput   group                "Hourly Fast MA Inputs"
input    int                  inpHourlyFastMAPeriod         =  50;                // Hourly Fast Period
input    ENUM_MA_METHOD       inpHourlyFastMAMethod         =  MODE_EMA;         // Hourly Fast Method
input    ENUM_APPLIED_PRICE   inpHourlyFastAppliedPrice     =  PRICE_CLOSE;      // Hourly Fast Applied Price
input    ENUM_TIMEFRAMES      inpHourlyFastTimeFrame        =  PERIOD_H1;        // Hourly Fast Timeframe

// Hourly slow inputs
sinput   group                "Hourly Slow MA Inputs"
input    int                  inpHourlySlowMAPeriod         =  200;               // Hourly Slow Period
input    ENUM_MA_METHOD       inpHourlySlowMAMethod         =  MODE_EMA;         // Hourly Slow Method
input    ENUM_APPLIED_PRICE   inpHourlySlowAppliedPrice     =  PRICE_CLOSE;      // Hourly Slow Applied Price
input    ENUM_TIMEFRAMES      inpHourlySlowTimeFrame        =  PERIOD_H1;        // Hourly Slow Timeframe

//+------------------------------------------------------------------+
//|global variables                                                  |
//+------------------------------------------------------------------+

int            max_lookback               =  inpDailySlowMAPeriod + 1;
string         indicatorName              =  "CB-SamCo v8";

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string         dailyFastIndicatorArgs     = (string)inpDailyFastMAPeriod + "Hr";
string         dailySlowIndicatorArgs     = (string)inpDailySlowMAPeriod + "Hr";
string         hourlyFastIndicatorArgs    = (string)inpHourlyFastMAPeriod + "Hr";
string         hourlySlowIndicatorArgs    = (string)inpHourlySlowMAPeriod + "Hr";

//+------------------------------------------------------------------+
//|buffers and handles                                               |
//+------------------------------------------------------------------+

//daily
double   dailyFastBuffer[], dailyFastValues[], dailySignal[];
double   dailySlowBuffer[], dailySlowValues[];
int      dailyFastHandle, dailySlowHandle;


//hourly
double   hourlyFastBuffer[], hourlyFastValues[], hourlySignal[];
double   hourlySlowBuffer[], hourlySlowValues[];
int      hourlyFastHandle, hourlySlowHandle;


//daily highs & lows
double   dailyHigh, dailyHighBuffer[];


//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
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

   SetIndexBuffer(4, dailySignal, INDICATOR_DATA);
   ArraySetAsSeries(dailySignal, true);

   SetIndexBuffer(5, hourlySignal, INDICATOR_DATA);
   ArraySetAsSeries(hourlySignal, true);

   SetIndexBuffer(6, dailyHighBuffer, INDICATOR_DATA);
   ArraySetAsSeries(dailyHighBuffer, true);




//--- handle creation
   dailyFastHandle   =  iMA(Symbol(), inpDailyFastTimeFrame, inpDailyFastMAPeriod, 0, inpDailyFastMAMethod, inpDailyFastAppliedPrice);
   dailySlowHandle   =  iMA(Symbol(), inpDailySlowTimeFrame, inpDailySlowMAPeriod, 0, inpDailySlowMAMethod, inpDailySlowAppliedPrice);
   hourlyFastHandle  =  iMA(Symbol(), inpHourlyFastTimeFrame, inpHourlyFastMAPeriod, 0, inpHourlyFastMAMethod, inpHourlyFastAppliedPrice);
   hourlySlowHandle  =  iMA(Symbol(), inpHourlySlowTimeFrame, inpHourlySlowMAPeriod, 0, inpHourlySlowMAMethod, inpHourlySlowAppliedPrice);


   if(dailyFastHandle == INVALID_HANDLE || dailySlowHandle == INVALID_HANDLE || hourlyFastHandle == INVALID_HANDLE || hourlySlowHandle == INVALID_HANDLE)
     {
      printf("Failed to create " + indicatorName + "handles");
      return(INIT_FAILED);
     }
   printf(indicatorName + " handles created successfully");


// print label
   Comment(indicatorName + " Fast Daily Timeframe: " + (string)inpDailyFastTimeFrame + " Lookback: " + (string)inpDailyFastMAPeriod + "\n" +
           indicatorName + " Slow Daily Timeframe: " + (string)inpDailySlowTimeFrame + " Lookback: " + (string)inpDailySlowMAPeriod + "\n" +
           indicatorName + " Fast Hourly Timeframe: " + (string)inpHourlyFastTimeFrame + " Lookback: " + (string)inpHourlyFastMAPeriod + "\n" +
           indicatorName + " Slow Hourly Timeframe: " + (string)inpHourlySlowTimeFrame + " Lookback: " + (string)inpHourlySlowMAPeriod);


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

   int limit = prev_calculated - 1;
   if(prev_calculated == 0)
      limit = 0;


//+------------------------------------------------------------------+
//| Download Missing History                                         |
//+------------------------------------------------------------------+

   static int  waitCount = 10;
   if(prev_calculated == 0)
     {
      if(waitCount > 0)
        {
         datetime t     =  iTime(Symbol(), inpDailySlowTimeFrame, 0);
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
      if(limit < int(inpDailySlowTimeFrame / Period()))
         limit = PeriodSeconds(inpDailySlowTimeFrame) / PeriodSeconds(Period());
      if(limit > ArraySize(time))
         limit = ArraySize(time);
     }


//+------------------------------------------------------------------+
//| for loop                                                         |
//+------------------------------------------------------------------+

   for(int i = limit - 1; i >= 0; i--)
     {

      //+------------------------------------------------------------------+
      //| moving averages                                                  |
      //+------------------------------------------------------------------+

      //get daily bar shift to reference on current timeframe
      int      dailyFastBar   = iBarShift(Symbol(), inpDailyFastTimeFrame, time[i], false);
      datetime dailyFastTime  = iTime(Symbol(), inpDailyFastTimeFrame, dailyFastBar);

      int      dailySlowBar   = iBarShift(Symbol(), inpDailySlowTimeFrame, time[i], false);
      datetime dailySlowTime  = iTime(Symbol(), inpDailySlowTimeFrame, dailySlowBar);



      //get hourly bar shift to reference on current timeframe
      int      hourlyFastBar  = iBarShift(Symbol(), inpHourlyFastTimeFrame, time[i], false);
      datetime hourlyFastTime = iTime(Symbol(), inpHourlyFastTimeFrame, hourlyFastBar);

      int      hourlySlowBar  = iBarShift(Symbol(), inpHourlySlowTimeFrame, time[i], false);
      datetime hourlySlowTime =  iTime(Symbol(), inpHourlySlowTimeFrame, hourlySlowBar);


      //declare statc arrays to copy over
      double   dailyFastArray[1], dailySlowArray[1];
      double   hourlyFastArray[1], hourlySlowArray[1];

      //copy ma handles into arrays
      int      copyDailyFastBuffer    =   CopyBuffer(dailyFastHandle, 0, dailyFastTime, 1, dailyFastArray);
      int      copyDailySlowBuffer    =   CopyBuffer(dailySlowHandle, 0, dailySlowTime, 1, dailySlowArray);
      int      copyHourlyFastBuffer   =   CopyBuffer(hourlyFastHandle, 0, hourlyFastTime, 1, hourlyFastArray);
      int      copyHourlySlowBuffer   =   CopyBuffer(hourlySlowHandle, 0, hourlySlowTime, 1, hourlySlowArray);

      //copy arrays to buffers
      dailyFastBuffer[i]   =  dailyFastArray[0];
      dailySlowBuffer[i]   =  dailySlowArray[0];
      hourlyFastBuffer[i]  =  hourlyFastArray[0];
      hourlySlowBuffer[i]  =  hourlySlowArray[0];

      //set bools for signals
      bool     dailyEMA_BULL   = (dailyFastBuffer[i]   >  dailySlowBuffer[i]);
      bool     dailyEMA_BEAR   = (dailyFastBuffer[i]   <  dailySlowBuffer[i]);
      bool     hourlyEMA_BULL  = (hourlyFastBuffer[i]  >  hourlySlowBuffer[i]);
      bool     hourlyEMA_BEAR  = (hourlyFastBuffer[i]  <  hourlySlowBuffer[i]);

      //define buy/sell signals
      dailyEMA_BULL  ? dailySignal[i]  = 1 : dailyEMA_BEAR  ? dailySignal[i]  = -1 : 0;
      hourlyEMA_BULL ? hourlySignal[i] = 1 : hourlyEMA_BEAR ? hourlySignal[i] = -1 : 0;



      //+------------------------------------------------------------------+
      //|highs & lows                                                      |
      //+------------------------------------------------------------------+

      //--- attached saily highs and lows to bufer
      dailyHighBuffer[i]       =  iHigh(Symbol(), PERIOD_D1, dailyFastBar);


     }

   return(rates_total);
  }//on calculate


//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   IndicatorRelease(dailyFastHandle);
   IndicatorRelease(dailySlowHandle);
   Comment("");
   Print(indicatorName + " removed");
  }
//+------------------------------------------------------------------+




//+------------------------------------------------------------------+
//| Todo                                                             |
//+------------------------------------------------------------------+







//+------------------------------------------------------------------+
//| Safe                                                             |
//+------------------------------------------------------------------+
/*

 int      dailyFastBar   = iBarShift(Symbol(), inpDailyFastTimeFrame, time[i], false);
      datetime dailyFastTime  = iTime(Symbol(), inpDailyFastTimeFrame, dailyFastBar);

      int      dailySlowBar   = iBarShift(Symbol(), inpDailySlowTimeFrame, time[i], false);
      datetime dailySlowTime  = iTime(Symbol(), inpDailySlowTimeFrame, dailySlowBar);




      int      hourlyFastBar  = iBarShift(Symbol(), inpHourlyFastTimeFrame, time[i], false);
      datetime hourlyFastTime = iTime(Symbol(), inpHourlyFastTimeFrame, hourlyFastBar);

      int      hourlySlowBar  = iBarShift(Symbol(), inpHourlySlowTimeFrame, time[i], false);
      datetime hourlySlowTime =  iTime(Symbol(), inpHourlySlowTimeFrame, hourlySlowBar);



      double dailyFastArray[1],dailySlowArray[1];
      double hourlyFastArray[1],hourlySlowArray[1];

      int copyDailyFastBuffer    = CopyBuffer(dailyFastHandle, 0, dailyFastTime, 1, dailyFastArray);
      int copyDailySlowBuffer    = CopyBuffer(dailySlowHandle, 0, dailySlowTime, 1, dailySlowArray);
      int copyHourlyFastBuffer   = CopyBuffer(hourlyFastHandle, 0, hourlyFastTime, 1, hourlyFastArray);
      int copyHourlySlowBuffer   = CopyBuffer(hourlySlowHandle, 0, hourlySlowTime, 1, hourlySlowArray);

      dailyFastBuffer[i]   = dailyFastArray[0];
      dailySlowBuffer[i]   = dailySlowArray[0];

      hourlyFastBuffer[i]  = hourlyFastArray[0];
      hourlySlowBuffer[i]  = hourlySlowArray[0];



*/



















/*



datetime       timeBarOpen;

//+------------------------------------------------------------------+
//| New Bar Control                                                  |
//+------------------------------------------------------------------+
   bool newBar = false;

   if(timeBarOpen != iTime(_Symbol, PERIOD_CURRENT, 0))
     {
      newBar = true;
      timeBarOpen = iTime(_Symbol, PERIOD_CURRENT, 0);
     }

     */
//+------------------------------------------------------------------+
