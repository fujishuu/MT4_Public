#include <MyLib.mqh>

#define MAGIC 201100711
#define COMMENT "EURJPY_M5_sell_on_rally_40~60"
extern double Leverage = 1.0; //レバレッジ
//extern double SLrate = 0.004;
//extern double Lots = 0.0027;
extern int Slippage = 3;

extern int FastEMA = 36;
extern int SlowEMA = 64;
extern int SignalSMA = 21;


extern int EntryATRPeriod = 65;
/*
extern double EntryATRMult2 = 2.8;
extern double EntryATRMultN = 1.5;
*/
extern double EntryATRMult0 = 2;
extern double EntryATRMult1 = 1.4;
extern double EntryATRMult = 1.425;

extern int Limit_index_peak = 4;
//extern double CloseATRMult = 1.6;
//extern double TPATRMult = 2.4;

//extern double SLATRMult = 2.9;		if( index_peak == 2 && hh-Close[1] > EntryATRMult1*iATR(NULL,5,EntryATRPeriod,index_peak) ) ret = -1;


extern int TLATRPeriod = 23;
extern double TLATRMult = 6.3;

extern int RangeHHindex = 75;
extern int LimitLLindex = 40;

extern int TSPeriod = 20;

//extern int LL_Breakout = 30;

//double TP1st = 0;
double SL1st = 0;

double TLON = 0;
extern double TLONRatio = 0.40;
int TLSwitch = 0;

int ObjectID = 100;
int EntrySignal(int magic)
{
	if( FastEMA > SlowEMA ) return(0);
//	if( EntryATRMult1 >= EntryATRMult2 || EntryATRMult2 >= EntryATRMult ) return(0);
	if( !( RangeHHindex > LimitLLindex) ) return(0);
//	if( !( LL_Breakout > LimitLLindex) ) return(0);
   // オープンポジションの計算
   double pos = MyCurrentOrders(MY_OPENPOS, magic);
	if( pos < 0 ) return(0);   

	double macd1 = iMACD(NULL, 0, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_MAIN, 1);   
	double macdsig1 = iMACD(NULL, 0, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_SIGNAL, 1);   
	if( macd1 >=  macdsig1 ) return(0);
//	if( macd1 >=  0 ) return(0);
	
   int ret = 0;
 
 	if(!( iHighest(NULL,5,MODE_HIGH,RangeHHindex,1) > iLowest(NULL,5,MODE_LOW,RangeHHindex,1) ) ) return(0);
 	
 	double HH = iHigh(NULL,5,iHighest(NULL,5,MODE_HIGH,RangeHHindex,1));
 	double LL = iLow(NULL,5,iLowest(NULL,5,MODE_LOW,RangeHHindex,1));
 	
 	int index_lowest = iLowest(NULL,5,MODE_LOW,RangeHHindex,1);		if( index_lowest == 1 ) return(0);
 	int index_peak = iHighest(NULL,5,MODE_HIGH, index_lowest-1 ,1);
 	double hh = iHigh(NULL,5,index_peak);	
 	
 	if(!( (hh-LL)/(HH-LL)>0.40 && (hh-LL)/(HH-LL)<0.60 ) ) return(0);

 	if( !( LimitLLindex >= index_lowest ) ) return(0);


//	if( index_lowest != iLowest(NULL,5,MODE_LOW,LL_Breakout,1) ) return(0);
//	if( iHighest(NULL,5,MODE_HIGH,RangeHHindex,1) == iHighest(NULL,5,MODE_HIGH,2*RangeHHindex,1) ) return(0); 
	
	
	if( index_peak > Limit_index_peak ) return(0);
   // 売りシグナル
   if( pos >=0 )											// Entry1S [ MACD TREND ]
   {
		if( index_peak == 1 && hh-Close[1] > EntryATRMult0*iATR(NULL,5,EntryATRPeriod,index_peak) ) ret = -1;
		if( index_peak == 2 && hh-Close[1] > EntryATRMult1*iATR(NULL,5,EntryATRPeriod,index_peak) ) ret = -1;
   	if( index_peak >= 3 && hh-Close[1] > (index_peak-1)*EntryATRMult*iATR(NULL,5,EntryATRPeriod,index_peak) ) ret = -1;
/*   	
		if( index_peak == 3 && hh-Close[1] > EntryATRMult2*iATR(NULL,5,EntryATRPeriod,index_peak) ) ret = -1;
		if( index_peak >= 4 && hh-Close[1] > EntryATRMult*iATR(NULL,5,EntryATRPeriod,index_peak) ) ret = -1;
		if( index_peak >= 3 && Close[2]-Close[1] > EntryATRMultN*iATR(NULL,5,EntryATRPeriod,index_peak) ) ret = -1;
*/
		if( ret == -1 )
		{
//		 TP1st = iClose(NULL,5,1) - TPATRMult*iATR(NULL,5,EntryATRPeriod,index_peak);
		 SL1st = hh; 	
//		 SL1st = MathMin(hh, Close[0] + SLATRMult*iATR(NULL,5,EntryATRPeriod,index_peak) );
	 	 TLON = LL + TLONRatio*(HH-LL);
		 string objname = "peak"+ObjectID;
		 string objHH = "HH"+ObjectID;
		 string objLL = "LL"+ObjectID;
		 ObjectCreate(objname,OBJ_ARROW,0,iTime(NULL,5,index_peak),hh); ObjectSet(objname,OBJPROP_COLOR,Pink);
		 ObjectCreate(objHH,OBJ_ARROW,0,iTime(NULL,5,iHighest(NULL,5,MODE_HIGH,RangeHHindex,1)),HH); ObjectSet(objHH,OBJPROP_COLOR,Red);
		 ObjectCreate(objLL,OBJ_ARROW,0,iTime(NULL,5,index_lowest),LL); ObjectSet(objLL,OBJPROP_COLOR,Blue);
		 ObjectID++;
		}
	}
//if( (iLow(NULL,1,1) < TP1st) || (iHigh(NULL,1,1) > SL1st) ) ret = 0;
   return(ret);
}

void Exit(int magic)
{
	
   for(int i=0; i<OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS) == false) break;
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != magic) continue;
   
      if(OrderType() == OP_SELL)
      {
//			if( (iLow(NULL,5,1) < TP1st) || (iHigh(NULL,5,1) > SL1st) )
//			{MyOrderClose(Slippage, MAGIC);	TP1st=0;SL1st=0;}
			double macd1 = iMACD(NULL, 0, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_MAIN, 1);   
			double macdsig1 = iMACD(NULL, 0, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_SIGNAL, 1);   
         if( macd1 > macdsig1 ) MyOrderClose(Slippage, MAGIC);
         break;
      }
   }
}
//extern int ATRPeriod = 5;     // トレイリングストップ用ATRの期間
//extern double ATRMult = 1.6;  // トレイリングストップ用ATRの倍率
void MyTrailingStopATR(int period, double mult, int magic)
{
   double spread = Ask-Bid;
   double atr = iATR(NULL, 0, period, 1) * mult;
   double HH = Low[1] + atr + spread;
   double LL = High[1] - atr;      

   for(int i=0; i<OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS) == false) break;
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != magic) continue;

      if(OrderType() == OP_BUY)
      {
         if(LL > OrderStopLoss()) MyOrderModify(LL, 0, magic);
         break;
      }
   
      if(OrderType() == OP_SELL)
      {
         if(HH < OrderStopLoss() || OrderStopLoss() == 0) MyOrderModify(HH, 0, magic);
         break;
      }
   }
}
//+------------------------------------------------------------------+
//| expert start function                                            |
//+------------------------------------------------------------------+
int start()
  {
//----
		   // 売買ロット数の計算
   double lots = CalculateLots(Leverage); 

  	int sig_entry = EntrySignal(MAGIC);		// if macd1<signal, entry(ret=-1)

   // 売り注文
   if(sig_entry < 0)
   {
//      MyOrderClose(Slippage, MAGIC);
//      MyOrderSend(OP_SELL, lots, Bid, Slippage, Bid*(1+SLrate), 0, COMMENT, MAGIC);
      MyOrderSend(OP_SELL, lots, Bid, Slippage, SL1st, 0, COMMENT, MAGIC);
   }

//	Exit(MAGIC);
//	MyTrailingStopATR(TLATRPeriod,TLATRMult,MAGIC);

	double pos = MyCurrentOrders(MY_OPENPOS, MAGIC);
	if( Low[1] < TLON && pos < 0 ) TLSwitch = 1;
	if( TLSwitch == 0 ) MyTrailingStopHL(TSPeriod,MAGIC);
	if( TLSwitch == 1 ) MyTrailingStopATR(TLATRPeriod,TLATRMult,MAGIC);
	if( pos == 0 ) TLSwitch = 0;
//----
   return(0);
  }
//+------------------------------------------------------------------+

// 通常のトレイリングストップ(TStype=0)
//extern int TSPoint = 30;   // トレイリングストップのポイント数
void MyTrailingStop(int ts, int magic)
{
   if(Digits == 3 || Digits == 5) ts *= 10;

   for(int i=0; i<OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS) == false) break;
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != magic) continue;

      if(OrderType() == OP_BUY)
      {
         double newsl = Bid-ts*Point;
         if(newsl >= OrderOpenPrice() && newsl > OrderStopLoss()) MyOrderModify(newsl, 0, magic);
         break;
      }

      if(OrderType() == OP_SELL)
      {
         newsl = Ask+ts*Point;
         if(newsl <= OrderOpenPrice() && (newsl < OrderStopLoss() || OrderStopLoss() == 0)) MyOrderModify(newsl, 0, magic);
         break;
      }
   }
}

// HLバンドトレイリングストップ(TStype=1)
//extern int TSPeriod = 5;   // トレイリングストップ用HLバンドの期間
void MyTrailingStopHL(int period, int magic)
{
   double spread = Ask-Bid;
   double HH = iCustom(Symbol(), 0, "HLBand", period, 1, 1)+spread;
   double LL = iCustom(Symbol(), 0, "HLBand", period, 2, 1);

   if(MyCurrentOrders(OP_BUY, magic) != 0) MyOrderModify(LL, 0, magic);
   if(MyCurrentOrders(OP_SELL, magic) != 0) MyOrderModify(HH, 0, magic);
}

// ロット数の計算
double CalculateLots(double leverage)
{
   string symbol = StringSubstr(Symbol(), 0, 3) + AccountCurrency();

   double conv = iClose(symbol, 0, 0);
   if(conv == 0) conv = 1;
   
   double lots = leverage * AccountFreeMargin() / 100000 / conv;

   double minlots = MarketInfo(Symbol(), MODE_MINLOT);
   double maxlots = MarketInfo(Symbol(), MODE_MAXLOT);
   int lots_digits = MathLog(1.0/minlots)/MathLog(10.0);
   lots = NormalizeDouble(lots, lots_digits);
   if(lots < minlots) lots = minlots;
   if(lots > maxlots) lots = maxlots;

   return(lots);
}


