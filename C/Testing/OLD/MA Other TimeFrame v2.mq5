//+------------------------------------------------------------------+
//|                                           MA Other TimeFrame.mq5 |
//|                              Copyright © 2020, Vladimir Karputov |
//|                     https://www.mql5.com/ru/market/product/43516 |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2020, Vladimir Karputov"
#property link      "https://www.mql5.com/ru/market/product/43516"
#property version   "1.000"
#property indicator_chart_window
#property indicator_buffers   1
#property indicator_plots     1
//--- the iMA plot
#property indicator_label1  "MA"
#property indicator_type1   DRAW_SECTION
#property indicator_color1  clrMediumPurple
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2
//--- indicator buffer
double   iMABuffer[];
//--- input parameters
input group             "MA"
input ENUM_TIMEFRAMES      Inp_MA_period        = PERIOD_D1;   // MA: timeframe
input int                  Inp_MA_ma_period     = 12;          // MA: averaging period
input int                  Inp_MA_ma_shift      = 0;           // MA: horizontal shift
input ENUM_MA_METHOD       Inp_MA_ma_method     = MODE_SMA;    // MA: smoothing type
input ENUM_APPLIED_PRICE   Inp_MA_applied_price = PRICE_CLOSE; // MA: type of price
//---
int      handle_iMA     = INVALID_HANDLE;    // variable for storing the handle of the iMA indicator
bool     m_init_error   = false;             // error on InInit
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- assignment of array to indicator buffer
   SetIndexBuffer(0, iMABuffer, INDICATOR_DATA);
//--- set shift
   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
//---
   if(Inp_MA_period == PERIOD_CURRENT || Inp_MA_period < Period())
     {
      string err_text = (TerminalInfoString(TERMINAL_LANGUAGE) == "Russian") ?
                        "'MA: timeframe' не может быть меньше или равно ('<=') текущего таймфрейма!" :
                        "'MA: timeframe' cannot be less or equal ('<=') of the current timeframe!";
      if(MQLInfoInteger(MQL_TESTER)) // when testing, we will only output to the log about incorrect input parameters
         Print(__FILE__, " ", __FUNCTION__, ", ERROR: ", err_text);
      else // if the Expert Advisor is run on the chart, tell the user about the error
         Alert(__FILE__, " ", __FUNCTION__, ", ERROR: ", err_text);
      //---
      m_init_error = true;
      return(INIT_SUCCEEDED);
     }
//--- create handle of the indicator iMA
   handle_iMA = iMA(Symbol(), Inp_MA_period, Inp_MA_ma_period, Inp_MA_ma_shift,
                    Inp_MA_ma_method, Inp_MA_applied_price);
//--- if the handle is not created
   if(handle_iMA == INVALID_HANDLE)
     {
      //--- tell about the failure and output the error code
      PrintFormat("Failed to create handle of the iMA indicator for the symbol %s/%s, error code %d",
                  Symbol(),
                  EnumToString(Inp_MA_period),
                  GetLastError());
      //--- the indicator is stopped early
      return(INIT_FAILED);
     }
//--- show the symbol/timeframe the Moving Average indicator is calculated for
   string  short_name = StringFormat("iMA(%s/%s, %d, %d, %s, %s)", Symbol(), EnumToString(Inp_MA_period),
                                     Inp_MA_ma_period, Inp_MA_ma_shift, EnumToString(Inp_MA_ma_method), EnumToString(Inp_MA_applied_price));
   IndicatorSetString(INDICATOR_SHORTNAME, short_name);
   PlotIndexSetString(0, PLOT_LABEL, "iMA(" + Symbol() + "/" + StringSubstr(EnumToString(Inp_MA_period), 7, -1) + ")");
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
   if(m_init_error)
      return(0);
//--- main loop
   int limit = prev_calculated - 1;
   if(prev_calculated == 0)
      limit = 0;
   for(int i = limit; i < rates_total; i++)
     {
      int i_bar_shift = iBarShift(Symbol(), Inp_MA_period, time[i], false);

      datetime i_time = iTime(Symbol(), Inp_MA_period, i_bar_shift);

      double arr_ma[1];

      int copy_buffer = CopyBuffer(handle_iMA, 0, i_time, 1, arr_ma);

      iMABuffer[i] = arr_ma[0];
     }
 
//--- return the prev_calculated value for the next call
return(rates_total);
  }
//+------------------------------------------------------------------+
//| Indicator deinitialization function                              |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   if(handle_iMA != INVALID_HANDLE)
      IndicatorRelease(handle_iMA);
  }
//+------------------------------------------------------------------+
