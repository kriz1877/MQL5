//**************************************************
//*  RoundNr.mq4 (No Copyright)                    *
//*                                                *
//*  Draws horizontal lines at round price levels  *
//*                                                *
//*  Written by: Totoro @ forexfactory.com         *
//**************************************************

#property indicator_chart_window

extern double LineSpace     = 1; // 1 unit = 0.01 of basic value (e.g. 1 USD cent)
extern color  LineColor     = DeepPink;
extern int    LineStyle     = 2;
extern string LineStyleInfo = "0=Solid,1=Dash,2=Dot,3=DashDot,4=DashDotDot";
extern string LineText      = "RoundNr ";

double LineSpaceOld;
double Hoch;
double Tief;
bool   FirstRun = true;

int deinit()
{
   double AbSpace = 0.01*LineSpace;
   double Oben    = MathRound(110*Hoch)/100;
   double Unten   = MathRound(80*Tief)/100;
   for(double i=0; i<=Oben; i+=AbSpace)
   {
      if(i<Unten) { continue; }
      ObjectDelete(LineText+DoubleToStr(i,2));
   }
   return(0);
}

int start()
{
   if(FirstRun)
   {
      Hoch = NormalizeDouble( High[iHighest(NULL,0,MODE_HIGH,Bars-1,0)], 2 );
      Tief = NormalizeDouble( Low[iLowest(NULL,0,MODE_LOW,Bars-1,0)], 2 );
      FirstRun = false;
   }
   else if(LineSpace != LineSpaceOld)
   {
      deinit();
      Hoch = NormalizeDouble( High[iHighest(NULL,0,MODE_HIGH,Bars-1,0)], 2 );
      Tief = NormalizeDouble( Low[iLowest(NULL,0,MODE_LOW,Bars-1,0)], 2 );
   }
   DrawLines();
   LineSpaceOld = LineSpace;
   return(0);
}

void DrawLines()
{
   double AbSpace = 0.01*LineSpace;
   double Oben    = MathRound(110*Hoch)/100;
   double Unten   = MathRound(80*Tief)/100;

   for(double i=0; i<=Oben; i+=AbSpace)
   {
      if(i<Unten) { continue; }
      string StringNr = DoubleToStr(i,2); // 2 digits number in object name
      if (ObjectFind(LineText+StringNr) != 0) // HLine not in main chartwindow
      {                     
         ObjectCreate(LineText+StringNr, OBJ_HLINE, 0, 0, i);
         ObjectSet(LineText+StringNr, OBJPROP_STYLE, LineStyle);
         ObjectSet(LineText+StringNr, OBJPROP_COLOR, LineColor);
      }
      else // Adjustments
      {
         ObjectSet(LineText+StringNr, OBJPROP_PRICE1, i);
         ObjectSet(LineText+StringNr, OBJPROP_STYLE, LineStyle);
         ObjectSet(LineText+StringNr, OBJPROP_COLOR, LineColor);
      }
   }
   WindowRedraw();
}