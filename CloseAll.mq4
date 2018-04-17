//+------------------------------------------------------------------+
//|                                                     CloseAll.mq4 |
//|                                                            shuji |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "shuji"
#property link      ""
#property version   "1.00"
#property strict

extern int Slippage = 3;
color ArrowColor[6] = {Blue, Red, Blue, Red, Blue, Red};

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
	CloseAll(Slippage);
   
  }
//+------------------------------------------------------------------+

bool CloseAll(int slippage)
{
   for(int i=0; i<OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS) == false) break;
      if(OrderClose(OrderTicket(), OrderLots(), OrderClosePrice(), slippage, ArrowColor[OrderType()]) != true) 
      {GetLastError(); return(false);}

	}	
	return(true);
}