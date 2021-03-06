#define MAGIC "counter"
#define COMMENT "shuji_test"
#property indicator_buffers 3

#include <Mylib.mqh>


extern double Lots = 1.0;
extern int Slippage = 3;
extern double Leverage = 5.0; //レバレッジ

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

double Bufmacd[10000];
// 外部パラメータ

/*      extern int KPeriod = 13;
      extern int DPeriod = 26;
      extern int Slowing = 9;
*/
extern int KPeriod = 5;
extern int DPeriod = 3;
extern int Slowing = 3;

extern int RSI_Period = 14;

extern double level1 = 20.0;
extern double level2 = 80.0;
extern double level3 = 30.0;
extern double level4 = 70.0;
extern double level5 = 10.0;
extern double level6 = 90.0;

extern int FastEMA = 10;		//10
extern int SlowEMA = 23;		//23
extern int SignalSMA = 8;		//8

extern int BandsPeriod = 20;
extern int StdDevPeriod = 20;

extern double SlopeOfMac_L = 0.005;
extern double SlopeOfMac_S = 0.004;
extern double CoefficientOfStd = 0.2;

			extern double Coefficient = 0.4;
			extern double Schreenmac = 0.01;
			extern double Diffmacd1 = 0.003;
			extern double Diffmacd2 = 0.002;


int init()
{
	SetIndexBuffer(0,Bufmacd);
	ArraySetAsSeries(Bufmacd,true);

}

extern double Band = 0.0;
int EntrySignal(int magic)
{
//		calculate open position
		double pos = MyCurrentOrders(MY_OPENPOS, magic);
		
		double macd1 = iMACD(NULL,0,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE, MODE_MAIN, 1);
		double macdsig1 = iMACD(NULL,0,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE, MODE_SIGNAL, 1);
		double macd2 = iMACD(NULL,0,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE, MODE_MAIN, 2);
		double macdsig2 = iMACD(NULL,0,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE, MODE_SIGNAL, 2);
		double rsi1 = iRSI(NULL,0,RSI_Period,PRICE_CLOSE,1);
		double sto1 = iStochastic(NULL, 0, KPeriod, DPeriod, Slowing, MODE_SMA, 0, MODE_MAIN, 1);
//		double stddev = iStdDev(NULL,0,StdDevPeriod,0,MODE_SMA,PRICE_CLOSE,1);
		double stddev = iCustom(NULL,0,"StdDev_shuji",StdDevPeriod,200,0,1); 
		double stddevA = iCustom(NULL,0,"StdDev_shuji",StdDevPeriod,200,1,1); 
		double stddevSigma = iCustom(NULL,0,"StdDev_shuji",StdDevPeriod,200,6,1);      
     
      double macd_day1 = iMACD(NULL,1440,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE, MODE_MAIN, 1);
      double macd_daysign1 = iMACD(NULL,1440,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE, MODE_SIGNAL, 1);
     
					//		ArraySetAsSeries(Bufmacd,true);

      					int limit = Bars - IndicatorCounted();
      					for(int j=0; j<limit; j++)
      					{
           					Bufmacd[j] = iMACD(NULL, 0, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_MAIN, j);  
      					}
					//      double mcsgL = iBandsOnArray(Bufmacd,0,BandsPeriod,1,0,MODE_LOWER,1);
					//      double mcsgH = iBandsOnArray(Bufmacd,0,BandsPeriod,1,0,MODE_UPPER,1);
      			//		double mcsgH = iCustom(NULL,0,"MACD_BB",FastEMA,SlowEMA,SignalSMA,BandsPeriod,3,1);
      			//		double mcsgL = iCustom(NULL,0,"MACD_BB",FastEMA,SlowEMA,SignalSMA,BandsPeriod,4,1);

      					double rsiav = 0.0;
      					for(int i=0; i>RSI_Period; i++)
      					{
         					rsiav += iRSI(NULL, 0, RSI_Period, PRICE_CLOSE, i);
      					}
      					rsiav /= RSI_Period;
  
		int ret = 0;

		//	buy signal
/*		if(pos <= 0 && macd2 <= macdsig2 && macd1 > macdsig1 && 0 > macd1 && rsiav > 50)	ret = 1;
		if(pos <= 0 && macd2 <= macdsig2 && macd1 > macdsig1 && macd1 > 0.005 )	ret = 1;
if( iBands(NULL, 0, BandsPeriod, 1, 0, PRICE_CLOSE, MODE_UPPER, 1) - iBands(NULL, 0, BandsPeriod, 1, 0, PRICE_CLOSE, MODE_MAIN, 1) > Band
&& iMA(NULL, 0, BandsPeriod, 0, MODE_SMA, PRICE_CLOSE, 2) - iMA(NULL, 0, BandsPeriod, 0, MODE_SMA, PRICE_CLOSE, 1) < 0)
{
if( rsi1 < 50 || sto1 < 50)
{
		if(pos <= 0 && macd2 <= macdsig2 && macd1 > macdsig1 && macd1 < Coefficient * mcsgL && macd1 - macd2 > Diffmac )	ret = 1;
		if(pos <= 0 && macd2 <= macdsig2 && macd1 > macdsig1 && mcsgL < (-1)*Schreenmac && macd1 < Coefficient * mcsgL && macd1 - macd2 > Diffmac )	ret = 1;
		if(pos <= 0 && macd2 <= 0 && macd1 > 0 && macd1 - macd2 > Diffmacd1 ) ret = 1;
		if(pos <= 0 && macd2 <= macdsig2 && macd1 > macdsig1 && macdsig1 > 0 && macd1 - macd2 > Diffmacd2 ) ret = 1;
		if(pos <= 0 && macd2 <= macdsig2 && macd1 > macdsig1 )	ret = 1;
}
}										*/


//		if(pos <=0 && macd2 <= macdsig2 && macd1 > macdsig1 && macd1 - macd2 > SlopeOfMac_L ) ret = 1;
//		if(pos <=0 && macd2 <= macdsig2 && macd1 < macdsig1 ) ret = 1;
//		if(pos <=0 && ( rsi1 >= 50 && sto1 >= 50 ) ) ret = 0;
//		if(pos <=0 && stddev < CoefficientOfStd * stddevSigma + stddevA) ret = 0;
		for( i=1; i<8; i++)
			{
//				if( pos <=0 && ( iRSI(NULL,0,RSI_Period,PRICE_CLOSE,i) < 30 ) ) ret = 0;
			}
		
//		if( macd_day1 <= 0) ret = 0;
//		if( macd_day1 <= macd_daysign1 ) ret = 0;


		//	sell signal

//		if(pos >=0 && macd2 >= macdsig2 && macd1 < macdsig1 && macd1 > Coefficient * mcsgH && macd2 - macd1 > SlopeOfMac_S ) ret = -1;
//		if(pos >=0 && macd2 >= macdsig2 && macd1 < macdsig1 && mcsgH > Schreenmac && macd1 > Coefficient * mcsgH && macd2 - macd1 > SlopeOfMac_S ) ret = -1;
//		if(pos >= 0 && macd2 >= 0 && macd1 < 0 && macd2 - macd1 > Diffmacd1 ) ret = -1;
//		if(pos >= 0 && macd2 >= macdsig2 && macd1 < macdsig1 && macdsig1 < 0 && macd2 - macd1 < Diffmacd2 ) ret = -1;


//		if(pos >=0 && macd2 >= macdsig2 && macd1 < macdsig1 && macd2 - macd1 > SlopeOfMac_S ) ret = -1;
		if(pos >=0 && macd2 >= macdsig2 && macd1 < macdsig1 ) ret = -1;
      if(pos >=0 && macd1 >=0 ) ret = 0;
//		if(pos >=0 && ( rsi1 <= 50 && sto1 <= 50 ) ) ret = 0;
//		if(pos >=0 && stddev < CoefficientOfStd * stddevSigma + stddevA) ret = 0;

		for( i=1; i<8; i++)
			{
//				if( pos >=0 && ( iRSI(NULL,0,RSI_Period,PRICE_CLOSE,i) > 70 )) ret = 0;
			}

		return(ret);
}

extern double Coefficient_RB_L = 0.4;
extern double Macslope_RB_L = 0.003;
int EntrySignalRB_L(int magic)
{
	//		calculate open position
	double pos = MyCurrentOrders(MY_OPENPOS, magic);
	int ret = 0;
	
		double macd1 = iMACD(NULL,0,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE, MODE_MAIN, 1);
		double macdsig1 = iMACD(NULL,0,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE, MODE_SIGNAL, 1);
		double macd2 = iMACD(NULL,0,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE, MODE_MAIN, 2);
		double macdsig2 = iMACD(NULL,0,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE, MODE_SIGNAL, 2);
 
      int limit = Bars - IndicatorCounted();
      for(int j=0; j<limit; j++)
      {
           Bufmacd[j] = iMACD(NULL, 0, FastEMA, SlowEMA, SignalSMA, PRICE_CLOSE, MODE_MAIN, j);  
      }
//      double mcsgL = iBandsOnArray(Bufmacd,0,BandsPeriod,1,0,MODE_LOWER,1);
//      double mcsgH = iBandsOnArray(Bufmacd,0,BandsPeriod,1,0,MODE_UPPER,1);

      double mcsgH = iCustom(NULL,0,"MACD_BB",FastEMA,SlowEMA,SignalSMA,BandsPeriod,3,1);
      double mcsgL = iCustom(NULL,0,"MACD_BB",FastEMA,SlowEMA,SignalSMA,BandsPeriod,4,1);

		if(pos <= 0 && macd2 <= macdsig2 && macd1 > macdsig1 && macd1 < Coefficient_RB_L * mcsgL && macd1 - macd2 > Macslope_RB_L )	ret = 1;
		
}


//extern int ATRPeriod = 5;     // トレイリングストップ用ATRの期間
//extern double ATRMult = 2.0;  // トレイリングストップ用ATRの倍率
extern int ATRPeriod = 5;     // トレイリングストップ用ATRの期間
extern double ATRMult = 3.0;  // トレイリングストップ用ATRの倍率
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

// 通常のトレイリングストップ(TStype=0)
//extern int TSPoint = 15;   // トレイリングストップのポイント数
extern int TSPoint = 30;   // トレイリングストップのポイント数
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
//extern int TSPeriod = 20;   // トレイリングストップ用HLバンドの期間
extern int TSPeriod = 20;   // トレイリングストップ用HLバンドの期間
void MyTrailingStopHL(int period, int magic)
{
   double spread = Ask-Bid;
   double HH = iCustom(Symbol(), 0, "HLBand", period, 1, 1)+spread;
   double LL = iCustom(Symbol(), 0, "HLBand", period, 2, 1);

   if(MyCurrentOrders(OP_BUY, magic) != 0) MyOrderModify(LL, 0, magic);
   if(MyCurrentOrders(OP_SELL, magic) != 0) MyOrderModify(HH, 0, magic);
}

extern int StoCrossPeriod = 8;
int FilterSignal(int signal)
{

	for(int i=0; i<StoCrossPeriod; i++)
	{
      int ret = signal;

		double sto = iStochastic(NULL,0,KPeriod,DPeriod,Slowing, MODE_SMA, 0, MODE_MAIN, i);
		
		if(signal > 0 && sto < level1) break;
		if(signal < 0 && sto > level2) break;
      
		ret = 0;
	}
	
	return(ret);
}

extern int MAPeriod = 5;
extern int MAMPeriod = 20;
extern int MALPeriod = 100;
extern int Slop_Period = 2;
extern double MADiff = 0.0;
int FilterSignalma(int signal)
{   	
   int ret = signal;
   for(int i=0; i<Slop_Period;i++)
   {
   	double mamiddle1 = iMA(NULL, 0, MAMPeriod, 0, MODE_SMA, PRICE_CLOSE, i);
	   double mamiddle2 = iMA(NULL, 0, MAMPeriod, 0, MODE_SMA, PRICE_CLOSE, i+1);

      double ma1 = iMA(NULL, 0, MAPeriod, 0, MODE_SMA, PRICE_CLOSE, i);
      double ma2 = iMA(NULL, 0, MAPeriod, 0, MODE_SMA, PRICE_CLOSE, i+1);
//      if(signal > 0 &&( ma1 - ma2 <=0 || mamiddle1 - mamiddle2 <=0)) ret = 0;
//     if(signal < 0 &&( ma1 - ma2 >=0 || mamiddle1 - mamiddle2 >=0)) ret = 0;
      if(signal > 0 && ma1 - ma2 < MADiff ) ret = 0;
      if(signal < 0 && ma1 - ma2 > (-1)*MADiff ) ret = 0;
   }
   
//   double mamiddle = iMA(NULL, 0, MAMPeriod, 0, MODE_SMA, PRICE_CLOSE, 1);
//   if(signal > 0 && Close[1] <= mamiddle ) ret =0;
//   if(signal < 0 && Close[1] >= mamiddle ) ret =0;
   
//   double malong = iMA(NULL, 0, MALPeriod, 0, MODE_SMA, PRICE_CLOSE, 1);
//   if(signal > 0 && Close[1] <= malong ) ret =0;
//   if(signal < 0 && Close[1] >= malong ) ret =0;
   
	return(ret);
}

extern int HLPeriod = 10;
extern double Coefficient2 = 0;
void SLTP(int magic)
{

		double macd1 = iMACD(NULL,0,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE, MODE_MAIN, 1);
		double macdsig1 = iMACD(NULL,0,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE, MODE_SIGNAL, 1);
		double macd2 = iMACD(NULL,0,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE, MODE_MAIN, 2);
		double macdsig2 = iMACD(NULL,0,FastEMA,SlowEMA,SignalSMA,PRICE_CLOSE, MODE_SIGNAL, 2);
		
		double rsi1 = iRSI(NULL,0,RSI_Period,PRICE_CLOSE,1);
		
		double sto1 = iStochastic(NULL, 0, KPeriod, DPeriod, Slowing, MODE_SMA, 0, MODE_MAIN, 1);
	
		double BBL = iBands(NULL, 0, BandsPeriod, 2, 0, PRICE_CLOSE, MODE_LOWER, 1);
		double BBH = iBands(NULL, 0, BandsPeriod, 2, 0, PRICE_CLOSE, MODE_UPPER, 1);

      double tpH = iCustom(NULL, 0, "HLband", HLPeriod, 1, 1);
      double tpL = iCustom(NULL, 0, "HLband", HLPeriod, 2, 1);
      double ma1 = iMA(NULL,0,HLPeriod,0,MODE_SMA,PRICE_CLOSE,1);
      
   for(int i=0; i<OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS) == false) break;
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != magic) continue;

      if(OrderType() == OP_BUY)
      {
//         if(macd2>=macdsig2 && macd1<macdsig1) MyOrderClose(Slippage, MAGIC);
         if(macd1<macdsig1) MyOrderClose(Slippage, MAGIC);
//         if(rsi1>level4) MyOrderClose(Slippage, MAGIC);
//         if(sto1>level6) MyOrderClose(Slippage, MAGIC);
//         if(High[1]>BBH) MyOrderClose(Slippage, MAGIC);
//         if(High[1]>tpH) MyOrderClose(Slippage, MAGIC);
//			if(High[1]> ma1 + (tpH - ma1)*(1 - Coefficient2) )	MyOrderClose(Slippage, MAGIC);
         break;
      }
   
      if(OrderType() == OP_SELL)
      {
//         if(macd2<=macdsig2 && macd1>macdsig1) MyOrderClose(Slippage, MAGIC);
         if(macd1>macdsig1) MyOrderClose(Slippage, MAGIC);
         if(rsi1<level3) MyOrderClose(Slippage, MAGIC);
         if(sto1<level5) MyOrderClose(Slippage, MAGIC);
//         if(Low[1]<BBL) MyOrderClose(Slippage, MAGIC);
//         if(Low[1]<tpL) MyOrderClose(Slippage, MAGIC);
//			if(Low[1]< ma1 - (ma1 - tpL)*(1 - Coefficient2) )	MyOrderClose(Slippage, MAGIC);
         break;
      }
   }
}

/*--------------start of Close_Oscillator_TP-------------------------------start of Close_Oscillator_TP-------------------------------start of Close_Oscillator_TP-----------------*/
extern int Close1S_RSI_Period = 14;
extern int Close1S_BandsPeriod = 20;

extern int Close1S_FastEMA = 13;
extern int Close1S_SlowEMA = 26;
extern int Close1S_SignalEMA = 9;
	extern double Close1S_rsi = 30;
	extern double Close1S_sto = 10;
	extern double Close1S_rsi_peak = 25;
	extern double Close1S_sto_peak = 3;	
extern int Close1S_sto_count = 7;

void Close_Oscillator_TP(int magic)
{
			double rsi1 = iRSI(NULL,0,Close1S_RSI_Period,PRICE_CLOSE,1);
			double rsi2 = iRSI(NULL,0,Close1S_RSI_Period,PRICE_CLOSE,2);
			double sto1 = iStochastic(NULL, 0, KPeriod, DPeriod, Slowing, MODE_SMA, 0, MODE_MAIN, 1);
			double stosig1 = iStochastic(NULL, 0, KPeriod, DPeriod, Slowing, MODE_SMA, 0, MODE_SIGNAL, 2);
			double sto2 = iStochastic(NULL, 0, KPeriod, DPeriod, Slowing, MODE_SMA, 0, MODE_MAIN, 1);
			double stosig2 = iStochastic(NULL, 0, KPeriod, DPeriod, Slowing, MODE_SMA, 0, MODE_SIGNAL, 2);
	
   for(int i=0; i<OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS) == false) break;
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != magic) continue;

      if(OrderType() == OP_BUY)
      {
//         if(macd2>=macdsig2 && macd1<macdsig1) MyOrderClose(Slippage, MAGIC);
         if(rsi1>level4) MyOrderClose(Slippage, MAGIC);
         if(sto1>level6) MyOrderClose(Slippage, MAGIC);
//         if(High[1]>BBH) MyOrderClose(Slippage, MAGIC);
//         if(High[1]>tpH) MyOrderClose(Slippage, MAGIC);
//			if(High[1]> ma1 + (tpH - ma1)*(1 - Coefficient2) )	MyOrderClose(Slippage, MAGIC);
         break;
      }
   
      if(OrderType() == OP_SELL)
      {
			if( rsi1 < Close1S_rsi_peak ) MyOrderClose(Slippage, MAGIC);
			if( sto1 < Close1S_sto_peak ) MyOrderClose(Slippage, MAGIC);

			if( rsi2 <= Close1S_rsi && rsi1 > Close1S_rsi) MyOrderClose(Slippage, MAGIC);
			
			if( rsi2 <= Close1S_rsi && rsi1 <= Close1S_rsi )
			{
				if( sto1 <= stosig1 && sto2 > Close1S_sto )
				{
					for( i=0; i<Close1S_sto_count; i++)
						{
							if( iStochastic(NULL, 0, KPeriod, DPeriod, Slowing, MODE_SMA, 0, MODE_MAIN, i) < Close1S_sto )
							break;
						}		
					MyOrderClose(Slippage, MAGIC);
				}
			}
 //       if(macd2<=macdsig2 && macd1>macdsig1) MyOrderClose(Slippage, MAGIC);
//         if(rsi1<Close1S_rsi) MyOrderClose(Slippage, MAGIC);
//         if(sto1<Close1S_sto) MyOrderClose(Slippage, MAGIC);
//			if(High[1]>BBH) MyOrderClose(Slippage, MAGIC);
//			if(rsi2>70 && rsi1>70 && High[2]<High[1]) MyOrderClose(Slippage, MAGIC);
//         if(Low[1]<BBL) MyOrderClose(Slippage, MAGIC);
//         if(Low[1]<tpL) MyOrderClose(Slippage, MAGIC);
//			if(Low[1]< ma1 - (ma1 - tpL)*(1 - Coefficient2) )	MyOrderClose(Slippage, MAGIC);
         break;
      }
   }
}
/*--------------end of Close_Oscillator_TP-------------------------------end of Close_Oscillator_TP-------------------------------end of Close_Oscillator_TP-----------------*/



int start()
{
	   // 売買ロット数の計算
   double lots = CalculateLots(Leverage); 

	int sig_entry = EntrySignal(MAGIC);

//	int sig_entry_RB_L = EntrySignalRB_L("RB_L");
//	sig_entry_RB_L = FilterSignal(sig_entry_RB_L);
	
//	sig_entry = FilterSignalma(sig_entry);
	
	if(sig_entry > 0) MyOrderSend(OP_BUY, lots, Ask, Slippage, 0, 0, COMMENT, MAGIC);
//	if(sig_entry < 0) MyOrderSend(OP_SELL, lots, Bid, Slippage, 0, 0, COMMENT, MAGIC);

//	if(sig_entry_RB_L > 0) MyOrderSend(OP_BUY, lots, Ask, Slippage, 0, 0, COMMENT, MAGIC);
	if(sig_entry < 0) MyOrderSend(OP_SELL, lots, Bid, Slippage, 0, 0, COMMENT, MAGIC);
	Close_Oscillator_TP(MAGIC);
	
	MyTrailingStopATR(ATRPeriod,ATRMult,MAGIC);
	MyTrailingStop(TSPoint,MAGIC);
	MyTrailingStopHL(TSPeriod,MAGIC);
	SLTP(MAGIC);
//	SLTP("RB_L");

	
		double stddev = iCustom(NULL,0,"StdDev_shuji",StdDevPeriod,200,0,1); 
		double stddevA = iCustom(NULL,0,"StdDev_shuji",StdDevPeriod,200,6,1);      

	Print("stddev=",stddev);
	Print("stddevA=",stddevA);
	return(0);
		Print("Bufmacd[10]=",Bufmacd[10]);

}

int deinit()
{
//	      double mcsgL = iBandsOnArray(Bufmacd,0,BandsPeriod,1,0,MODE_LOWER,1);
//      double mcsgH = iBandsOnArray(Bufmacd,0,BandsPeriod,1,0,MODE_UPPER,1);
//      double mcsgH = iCustom(NULL,0,"MACD_BB",FastEMA,SlowEMA,SignalSMA,3,1);

	return (0);
}