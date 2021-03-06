//+------------------------------------------------------------------+
//|                                                      junbari.mq4 |
//|                                                            shuji |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "shuji"
#property link      ""
#property version   "1.00"
#property strict
#include <MyLib.mqh>

extern int MAGIC1 = 201508231;
extern int MAGIC2 = 201508232;

extern int Slippage = 3;
extern double Lots = 0.01;

extern bool Buy_on = true;
extern int MoveBuy = 1300;
extern int PeriodBuy = 40;
extern int TL_Buy = 1200;
extern bool eq_SL_TP_Buy = false;
extern int TP_Buy = 1000;

extern bool Sell_on = true;
extern int MoveSell = 1400;
extern int PeriodSell = 30;
extern int TL_Sell = 700;
extern bool eq_SL_TP_Sell = false;
extern int TP_Sell = 1200;

int sigBuy()
{
	int ret = 0;
	if(Buy_on==false) return(0);
	int ihigh = iHighest(NULL,0,MODE_HIGH,PeriodBuy-1,2);
	double high = High[ihigh];
	int ilow = iLowest(NULL,0,MODE_LOW,PeriodBuy,1);
	double low = Low[ilow];
	if(Close[1]>high && Close[1]-low>MoveBuy*_Point) ret = 1;
	return(ret);
}

int sigSell()
{
	int ret = 0;
	if(Sell_on==false) return(0);
	int ilow = iLowest(NULL,0,MODE_LOW,PeriodSell-1,2);
	double low = Low[ilow];
	int ihigh = iHighest(NULL,0,MODE_HIGH,PeriodSell,1);
	double high = High[ihigh];
	if(Close[1]<low && high-Close[1]>MoveSell*_Point) ret = 1;
	return(ret);
}

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---
   
  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---		
   int slippage = Slippage;
   if(Digits==3 || Digits==5) slippage *= 10;
	double spread = Ask - Bid;

	double TLW_buy = TL_Buy*_Point;
	double LL = High[1] - TLW_buy;
   double pos1 = MyCurrentOrders(MY_OPENPOS, MAGIC1);
   if(pos1==0 && sigBuy()>0)
   {
   	if(eq_SL_TP_Buy==true)  MyOrderSend(OP_BUY, Lots, Ask, slippage, Ask-TL_Buy*Point, Ask+TL_Buy*Point, "", MAGIC1);
   	else if(eq_SL_TP_Buy==false) MyOrderSend(OP_BUY, Lots, Ask, slippage, Ask-TL_Buy*Point, Ask+TP_Buy*Point, "", MAGIC1);
	}

	for(int i=0; i<OrdersTotal(); i++)
	{
		if(OrderSelect(i, SELECT_BY_POS) == false)	break;
		if(OrderSymbol() != Symbol() || OrderMagicNumber() != MAGIC1)	continue;
		if(LL > OrderStopLoss() )	MyOrderModify(LL, 0, MAGIC1);
		break;
	}

	double TLW_sell = TL_Sell*_Point;
	double HH = Low[1] + TLW_sell + spread;
	double pos2 = MyCurrentOrders(MY_OPENPOS, MAGIC2);
   if(pos2==0 && sigSell()>0)
   {
   	if(eq_SL_TP_Sell==true)  MyOrderSend(OP_SELL, Lots, Bid, slippage, Bid+TL_Sell*Point, Bid-TL_Sell*Point, "", MAGIC2);
   	else if(eq_SL_TP_Sell==false) MyOrderSend(OP_SELL, Lots, Bid, slippage, Bid+TL_Sell*Point, Bid-TP_Sell*Point, "", MAGIC2);
	}
	
	for(int i=0; i<OrdersTotal(); i++)
	{
		if(OrderSelect(i, SELECT_BY_POS) == false)	break;
		if(OrderSymbol() != Symbol() || OrderMagicNumber() != MAGIC2)	continue;
		if(HH < OrderStopLoss() )	MyOrderModify(HH, 0, MAGIC2);
		break;
	}


  }
//+------------------------------------------------------------------+
