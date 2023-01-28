//+------------------------------------------------------------------+
//|                                            CB-Simple_MACross.mq4 |
//|                                   Copyright 2021, Chris Bakowski |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, Chris Bakowski"
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict
#property show_inputs
#property indicator_chart_window
#property indicator_buffers 21
#property indicator_plots   21


#include <CB-CustomFunctionsMQL4.mqh>


extern   string      Indicator_Settings; //Indicator_Settings Settings -------------------------------------------
input    int         swingLookback           =  10;
extern   bool        useRSI                  =  true;
input    int         Extended_Level          =  20;
input    int         RSI_Period              =  8;

extern   string      Print_Settings; //Print_Settings Settings -------------------------------------------
input    bool        PrintDebug              =  false;
input    bool        Candle_Notifications    =  false;
input    bool        Print_Candles           =  false;
extern  bool         Show_High_Lows          =  false;
input    int         candleLabels            =  2;


//--- Constants
int                  RSI_Overbought_Level    =  100 - Extended_Level;
int                  RSI_Oversold_Level      =  0   + Extended_Level;
datetime             candletime              =  0;
datetime             currenttime             =  0;

//--- Variables
int            max_lookback               =  10;
color          High_Color, Low_Color;

//---Buffers
double         Daily_Fast_Buffer[], Daily_Slow_Buffer[], Daily_MA_Signal[];
double         Hourly_Fast_Buffer[],  Hourly_Slow_Buffer[], Hourly_MA_Signal[];

//--- Dily Highs & Lows
double         Daily_High, Daily_Low, Daily_High_Buffer[], Daily_Low_Buffer[], HighLowOfDay[];

//--- Daily tally
int            New_Daily_Candle, New_Day_Tally;
double         New_Daily_Candle_Buffer[], New_Day_Tally_Buffer[];

//--- Signals
double         Down_Arrow[], Up_Arrow[], Trade_Signal[], RSI_Signal[];

//--- Candlesticks
bool           EMA_Bull, EMA_Bear, PB_Bull, PB_Bear;
double         PB_Bull_Buffer[],PB_Bear_Buffer[],EC_Bull_Buffer[],EC_Bear_Buffer[],Candle_Buffer[], TV_Bull_Buffer[], TV_Bear_Buffer[];

//--- Swings
double         SwingHighPrice[], SwingLowPrice[], Swing[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- High colours

   High_Color = Show_High_Lows ? clrDarkOrange : clrNONE;
   Low_Color  = Show_High_Lows ? clrDarkBlue   : clrNONE;


//--- indicator buffers mapping

//---  Daily
   SetIndexBuffer(0,Daily_Fast_Buffer);
   SetIndexStyle(0,DRAW_LINE,STYLE_SOLID,3,clrRed);
   SetIndexLabel(0,NULL);

   SetIndexBuffer(1,Daily_Slow_Buffer);
   SetIndexStyle(1,DRAW_LINE,STYLE_SOLID,3,clrGreen);
   SetIndexLabel(1,NULL);

   SetIndexBuffer(2,Daily_MA_Signal);
   SetIndexStyle(2,DRAW_NONE);
   SetIndexLabel(2,"Daily Signal");

//--- Hourly
   SetIndexBuffer(3,Hourly_Fast_Buffer);
   SetIndexStyle(3,DRAW_LINE,STYLE_SOLID,2,clrRed);
   SetIndexLabel(3,NULL);

   SetIndexBuffer(4,Hourly_Slow_Buffer);
   SetIndexStyle(4,DRAW_LINE,STYLE_SOLID,2,clrGreen);
   SetIndexLabel(4,NULL);

   SetIndexBuffer(5,Hourly_MA_Signal);
   SetIndexStyle(5,DRAW_NONE);
   SetIndexLabel(5,"Hourly Signal");


//--- Daily Highs
   SetIndexBuffer(6,Daily_High_Buffer);
   SetIndexStyle(6,DRAW_LINE,STYLE_SOLID,2,High_Color);
   SetIndexLabel(6,NULL);

   SetIndexBuffer(7,Daily_Low_Buffer);
   SetIndexStyle(7,DRAW_LINE,STYLE_SOLID,2,Low_Color);
   SetIndexLabel(7,NULL);

   SetIndexBuffer(8,HighLowOfDay);
   SetIndexStyle(8,DRAW_NONE,clrNONE);
   SetIndexLabel(8,"HighLowOfDay");


//--- Visual Signals
   SetIndexBuffer(9,Down_Arrow);
   SetIndexStyle(9,DRAW_ARROW,0,3,clrRed);
   SetIndexArrow(9,234);
   SetIndexLabel(9,NULL);

   SetIndexBuffer(10,Up_Arrow);
   SetIndexStyle(10,DRAW_ARROW,0,3,clrGreen);
   SetIndexArrow(10,233);
   SetIndexLabel(10,NULL);

   SetIndexBuffer(11,Trade_Signal);
   SetIndexLabel(11,"Trade_Signal");


//--- PB_mapping
   SetIndexBuffer(12,PB_Bull_Buffer);
   SetIndexStyle(12,DRAW_ARROW,0,candleLabels,clrGreen);
   SetIndexArrow(12,140);
   SetIndexLabel(12,NULL);

   SetIndexBuffer(13,PB_Bear_Buffer);
   SetIndexStyle(13,DRAW_ARROW,0,candleLabels,clrRed);
   SetIndexArrow(13,140);
   SetIndexLabel(13,NULL);

//--- engulfing mapping
   SetIndexBuffer(14,EC_Bull_Buffer);
   SetIndexStyle(14,DRAW_ARROW,0,candleLabels,clrGreen);
   SetIndexArrow(14,141);
   SetIndexLabel(14,NULL);

   SetIndexBuffer(15,EC_Bear_Buffer);
   SetIndexStyle(15,DRAW_ARROW,0,candleLabels,clrRed);
   SetIndexArrow(15,141);
   SetIndexLabel(15,NULL);

//--- candle signal mapping
   SetIndexBuffer(16,Candle_Buffer);
   SetIndexStyle(16,DRAW_NONE);
   SetIndexLabel(16,"Candle");


//--- swings
   SetIndexBuffer(17,SwingHighPrice);
   SetIndexStyle(17,DRAW_NONE);
   SetIndexLabel(17,NULL);

//--- candle signal mapping
   SetIndexBuffer(18,SwingLowPrice);
   SetIndexStyle(18,DRAW_NONE);
   SetIndexLabel(18,NULL);

   SetIndexBuffer(19,Swing);
   SetIndexStyle(19,DRAW_NONE);
   SetIndexLabel(19,"Swing");

//--- rsi signal
   SetIndexBuffer(20,RSI_Signal);
   SetIndexStyle(20,DRAW_NONE);
   SetIndexLabel(20,"RSI_Signal");


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

   currenttime = Time[0];
   int limit = rates_total - prev_calculated;

//+------------------------------------------------------------------+
//| Call Missing Chart History                                       |
//+------------------------------------------------------------------+

   static int Wait_Count = 10;
   if(prev_calculated==0)
     {
      if(Wait_Count>0)
        {
         datetime HT = iTime(Symbol(),PERIOD_D1,0);
         int err     = GetLastError();
         if(HT==0)
           {
            Wait_Count--;
            PrintFormat("Waiting for data");
            return(prev_calculated);
           }
         PrintFormat("Data is now available");
        }
      else
        {
         Print("Timed-out waiting for data");
        }
     }

//+------------------------------------------------------------------+
//| Repainting Function                                              |
//+------------------------------------------------------------------+


   if(prev_calculated>0)
     {
      if(limit    <  int(PERIOD_D1/Period()))
         limit    =  int(PERIOD_D1/Period());

      if(limit    >  ArraySize(time))
         limit    =  ArraySize(time);
     }

//+------------------------------------------------------------------+
//| For Loop                                                         |
//+------------------------------------------------------------------+

   for(int i=1; i<limit-max_lookback; i++)
     {

      //+------------------------------------------------------------------+
      //| HTF bars                                                         |
      //+------------------------------------------------------------------+

      int Daily_Bar           = iBarShift(Symbol(),PERIOD_D1,time[i], false);
      int Hourly_Bar          = iBarShift(Symbol(),PERIOD_H1,time[i], false);

      //+------------------------------------------------------------------+
      //| Moving Averages                                                  |
      //+------------------------------------------------------------------+

      //---Daily MAs
      Daily_Fast_Buffer[i]  = iMA(Symbol(),PERIOD_D1,8,0,MODE_EMA,PRICE_CLOSE,Daily_Bar);
      Daily_Slow_Buffer[i]  = iMA(Symbol(),PERIOD_D1,21,0,MODE_EMA,PRICE_CLOSE,Daily_Bar);

      bool Daily_EMA_BULL     = (Daily_Fast_Buffer[i] > Daily_Slow_Buffer[i]);
      bool Daily_EMA_BEAR     = (Daily_Fast_Buffer[i] < Daily_Slow_Buffer[i]);

      Daily_EMA_BULL ? Daily_MA_Signal[i] = 1 : Daily_EMA_BEAR ? Daily_MA_Signal[i] = -1 : 0;


      //---Hourly MAs
      Hourly_Fast_Buffer[i] = iMA(Symbol(),PERIOD_H1,50,0,MODE_EMA,PRICE_CLOSE,Hourly_Bar);
      Hourly_Slow_Buffer[i] = iMA(Symbol(),PERIOD_H1,200,0,MODE_EMA,PRICE_CLOSE,Hourly_Bar);

      bool One_Hour_EMA_BULL  = (Hourly_Fast_Buffer[i] > Hourly_Slow_Buffer[i]);
      bool One_Hour_EMA_BEAR  = (Hourly_Fast_Buffer[i] < Hourly_Slow_Buffer[i]);

      One_Hour_EMA_BULL ? Hourly_MA_Signal[i] = 1 : One_Hour_EMA_BEAR ? Hourly_MA_Signal[i] = -1 : 0;

      //--- ema signal based on alignment of MAs
      EMA_Bull = (Daily_MA_Signal[i] ==  1) && (Hourly_MA_Signal[i] ==  1);
      EMA_Bear = (Daily_MA_Signal[i] == -1) && (Hourly_MA_Signal[i] == -1);




      //+------------------------------------------------------------------+
      //|Highs_Lows                                                        |
      //+------------------------------------------------------------------+

      //--- attached saily highs and lows to bufer
      Daily_High_Buffer[i]       =  iHigh(Symbol(),PERIOD_D1,Daily_Bar);
      Daily_Low_Buffer[i]        =  iLow(Symbol(),PERIOD_D1,Daily_Bar);

      //--- boolean to define if it is or isnt daily high
      bool isDailyHigh           =  High[i] == Daily_High_Buffer[i];
      bool isDailyLow            =  Low[i]  == Daily_Low_Buffer[i];

      //--- daily signal based on boolean daily high
      HighLowOfDay[i] = isDailyHigh ? -1 : isDailyLow ? 1 : EMPTY_VALUE;

      //+------------------------------------------------------------------+
      //|Market conditions                                                 |
      //+------------------------------------------------------------------+

      // check whter the past 3 candles from i are swing lows or hihgs
      bool              isSwingHigh       = IsSwingHigh(i,10,i);
      bool              isSwingLow        = IsSwingLow(i,10,i);

      Swing[i] = isSwingHigh ? -1 : isSwingLow ? 1 : EMPTY_VALUE;



      //+------------------------------------------------------------------+
      //| Candles                                                          |
      //+------------------------------------------------------------------+

      //--- EC_Bull
      if(EC_Bull(i,Print_Candles,PrintDebug) && EMA_Bull && isSwingLow)
        {
         EC_Bull_Buffer[i] = Low [i] - Shift * 2;
         Candle_Buffer[i]  =  2;
         if(Candle_Notifications)
           {
            SendNotification("EC_Bull on "+ Symbol() + " at " + (string)TimeCurrent());
           }
        }

      //--- EC_Bear
      if(EC_Bear(i,Print_Candles,PrintDebug) && EMA_Bear && isSwingHigh)
        {
         EC_Bear_Buffer[i] = High [i] + Shift * 2;
         Candle_Buffer[i]  =  -2;
         if(Candle_Notifications)
           {
            SendNotification("EC_Bear on "+ Symbol() + " at " + (string)TimeCurrent());
           }
        }

      //--- PB_Green_Bull
      if((PB_Bull_JD(i,Print_Candles,PrintDebug) && EMA_Bull && isSwingLow) || (PB_Bull_TV(i,Print_Candles,PrintDebug)&& EMA_Bull && isSwingLow))
        {
         PB_Bull_Buffer[i] = Low [i] - Shift * 2;
         Candle_Buffer[i]  =   1;
         if(Candle_Notifications)
           {
            SendNotification("PB_Bull on "+ Symbol() + " at " + (string)TimeCurrent());
           }
        }

      //--- PB_Green_Bear
      if((PB_Bear_JD(i,Print_Candles,PrintDebug) && EMA_Bear && isSwingHigh) || (PB_Bear_TV(i,Print_Candles,PrintDebug)&& EMA_Bear && isSwingHigh))
        {
         PB_Bear_Buffer[i] = High [i] + Shift * 2;
         Candle_Buffer[i]  =  -1;
         if(Candle_Notifications)
           {
            SendNotification("PB_Bear on "+ Symbol() + " at " + (string)TimeCurrent());
           }
        }

      //+------------------------------------------------------------------+
      //| RSI                                                              |
      //+------------------------------------------------------------------+

      double   RSI            =  iRSI(Symbol(),PERIOD_CURRENT,RSI_Period,PRICE_CLOSE,i);

      bool     RSI_Overbought =  RSI > RSI_Overbought_Level;
      bool     RSI_Oversold   =  RSI < RSI_Oversold_Level;

      RSI_Oversold ? RSI_Signal[i] = 1 : RSI_Overbought ? RSI_Signal[i] = -1 : 0;




      //+------------------------------------------------------------------+
      //| Master Trade Signal                                              |
      //+------------------------------------------------------------------+

      bool  Short_Signal   = (HighLowOfDay[i] ==  -1)
                             && ((Candle_Buffer[i] == -1) || (Candle_Buffer[i] == -2));


      bool  Long_Signal    = (HighLowOfDay[i] ==   1)
                             && ((Candle_Buffer[i] ==  1) || (Candle_Buffer[i] ==  2));


      if(Short_Signal)
        {
         Down_Arrow[i]     =  High[i] + Shift;
         Trade_Signal[i]   =  -1;
         if(currenttime!=candletime && i==1)
           {
            //SendNotification("GoShort on"+Symbol()+"at "+(string)TimeCurrent()); 
           }
         candletime=Time[0];
        }

      if(Long_Signal)
        {
         Up_Arrow[i]       =  Low[i] - Shift;
         Trade_Signal[i]   =   1;
          if(currenttime!=candletime && i==1)
           {
            //SendNotification("GoLong on"+Symbol()+"at "+(string)TimeCurrent()); 
           }
         candletime=Time[0];
        }

     }//for loop
//--- return value of prev_calculated for next call
   return(rates_total);
  }



//+------------------------------------------------------------------+
//|  Resources                                                       |
//+------------------------------------------------------------------+
// https://www.earnforex.com/guides/how-to-execute-an-action-only-once-per-bar-with-mql4/
