#property copyright "forex-station.com"
#property link      "forex-station.com"

#property indicator_chart_window
extern int             GridSpace  = 50;
extern color           lineColor  = clrDimGray;    
extern ENUM_LINE_STYLE lineStyle  = STYLE_DOT;       
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {

//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custor indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   ObjectsDeleteAll(0,"Grid");
   double shift=0;
   double HighPrice=0;
   double LowPrice=0;
   
   double Divisor = 0.1/Point;
   
   HighPrice = MathRound(High[iHighest(NULL,0,2, Bars - 2,  2)] * Divisor);
   //SL = High[Highest(MODE_HIGH, SLLookback, SLLookback)];
   LowPrice = MathRound(Low[iLowest(NULL,0,1, Bars - 1, 2)] * Divisor);
   //for(shift=LowPrice;shift<=HighPrice;shift++)
   //{
   //   ObjectDelete("Grid"+shift);   
   //}
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int    counted_bars=IndicatorCounted();
   double I=0;
   double HighPrice=0;
   double LowPrice=0;
   int GridS=0;
   int SL=0;
   int    digits     = (int)MarketInfo(OrderSymbol(),MODE_DIGITS);
   double point      = MarketInfo(OrderSymbol(),MODE_POINT);
   double PointRatio = MathPow(10,MathMod(digits,2));    
//----    

   double Divisor = 0.1/point/PointRatio;

   HighPrice = MathRound(High[iHighest(NULL,0,MODE_HIGH, Bars - 2, 2)] * Divisor);
   //SL = High[Highest(MODE_HIGH, SLLookback, SLLookback)];
   LowPrice = MathRound(Low[iLowest(NULL,0,MODE_LOW, Bars - 1, 2)] * Divisor);
   GridS = GridSpace / 10;
   
   for(I=LowPrice;I<=HighPrice;I++)
   {
	  //Print("mod(I, GridSpace): " + MathMod(I, GridS) + " I= " + I);
	  //Print(LowPrice + " " + HighPrice);
	  if (MathMod(I, GridS) == 0) 
	  {	     
         if (ObjectFind("Grid"+I) != 0)
         {                     
            ObjectCreate("Grid"+I, OBJ_HLINE, 0, Time[1], I/Divisor);            
            ObjectSet("Grid"+I, OBJPROP_STYLE, lineStyle);
            ObjectSet("Grid"+I, OBJPROP_COLOR, lineColor);            
         }
		 //MoveObject(I + "Grid", OBJ_HLINE, Time[Bars - 2], I/1000, Time[1], I/1000, MediumSeaGreen, 1, STYLE_SOLID);
	  }
   }
//----
   return(0);
  }
//+------------------------------------------------------------------+