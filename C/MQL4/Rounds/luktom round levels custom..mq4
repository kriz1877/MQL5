//+------------------------------------------------------------------+
//|                                          luktom round levels.mq4 |
//|                                   luktom :: £ukasz Tomaszkiewicz |
//|                                               http://luktom.biz/ |
//+------------------------------------------------------------------+
//|                                                                  |
//| Licencja dostêpna pod adresem:                                   |
//| http://go.luktom.biz/licencja_wskazniki_darmowe                  |
//|                                                                  |
//+------------------------------------------------------------------+

#property copyright "£ukasz Tomaszkiewicz :: luktom"
#property link      "http://luktom.biz/"

#property indicator_chart_window 

extern int   levels=1;
extern int   zoneSize=50;
extern color levelColor=White;
extern int   levelStyle=STYLE_DOT;
extern color zoneColor=Orange;
extern color zoneColor1=Lime;
int multiplier=10; 
int rem=2;
 int   x=100;
int init() {
  
  deinit();
  
  if(Digits==3 || Digits==5) {
   multiplier=10;
   rem=3;
  } else {
   multiplier=1;
   rem=2;
  }
   
  RefreshRates();
  
  double nearestLevel=NormalizeDouble(Bid,Digits-rem);

  for(int i=-levels;i<levels;i++) {
  
   string name="lrl"+i;
   string namer="lrlrect"+i;
   string namer1="lrlrect1"+i;
   if(ObjectFind(name)==-1) {
    ObjectCreate(name,OBJ_HLINE,0,0,0,0);  
   }
   
   ObjectSet(name,OBJPROP_PRICE1,nearestLevel+i*x*Point*multiplier);
   ObjectSet(name,OBJPROP_COLOR,levelColor);
   ObjectSet(name,OBJPROP_STYLE,levelStyle);
  
   if(zoneSize>0) {
    if(ObjectFind(namer)==-1) {
     ObjectCreate(namer,OBJ_RECTANGLE,0,0,0,0);
    }
  
    ObjectSet(namer,OBJPROP_PRICE1,nearestLevel+(i*x+zoneSize)*Point*multiplier);
    ObjectSet(namer,OBJPROP_PRICE2,nearestLevel+(i*x)*Point*multiplier);
    ObjectSet(namer,OBJPROP_TIME1,0);
    ObjectSet(namer,OBJPROP_TIME2,TimeLocal()+60*24*30*10*Period()); 
    ObjectSet(namer,OBJPROP_COLOR,zoneColor);
   }
  if(ObjectFind(namer1)==-1) {
     ObjectCreate(namer1,OBJ_RECTANGLE,0,0,0,0);
    }
  
    ObjectSet(namer1,OBJPROP_PRICE1,nearestLevel+(i*x)*Point*multiplier);
    ObjectSet(namer1,OBJPROP_PRICE2,nearestLevel+(i*x-zoneSize)*Point*multiplier);
    ObjectSet(namer1,OBJPROP_TIME1,0);
    ObjectSet(namer1,OBJPROP_TIME2,TimeLocal()+60*24*30*10*Period());
    ObjectSet(namer1,OBJPROP_COLOR,zoneColor1);
   } 
   

  return(0);
}

int deinit() {

   for(int i=-levels;i<levels;i++) {
    ObjectDelete("lrl" + i);
    ObjectDelete("lrlrect" + i);
    ObjectDelete("lrlrect1" + i);
   }

   return(0);
}

int start() {
   init();
   return(0);
}

