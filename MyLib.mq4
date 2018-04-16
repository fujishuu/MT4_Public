//+------------------------------------------------------------------+
//|                                                        MyLib.mq4 |
//|                                   Copyright (c) 2009, Toyolab FX |
//|                                         http://forex.toyolab.com |
//+------------------------------------------------------------------+
#property copyright "Copyright (c) 2009, Toyolab FX"
#property link      "http://forex.toyolab.com"
#property library

// マイライブラリー
#include <MyLib.mqh>

// 注文時の矢印の色
color ArrowColor[6] = {Blue, Red, Blue, Red, Blue, Red};

// 注文待ち時間(秒)
int MyOrderWaitingTime = 10;

// 現在のポジションのロット数（＋：買い －：売り）
double MyCurrentOrders(int type, int magic)
{
   double lots = 0.0;

   for(int i=0; i<OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS) == false) break;
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != magic) continue;

      switch(type)
      {
         case OP_BUY:
            if(OrderType() == OP_BUY) lots += OrderLots();
            break;
         case OP_SELL:
            if(OrderType() == OP_SELL) lots -= OrderLots();
            break;
         case OP_BUYLIMIT:
            if(OrderType() == OP_BUYLIMIT) lots += OrderLots();
            break;
         case OP_SELLLIMIT:
            if(OrderType() == OP_SELLLIMIT) lots -= OrderLots();
            break;
         case OP_BUYSTOP:
            if(OrderType() == OP_BUYSTOP) lots += OrderLots();
            break;
         case OP_SELLSTOP:
            if(OrderType() == OP_SELLSTOP) lots -= OrderLots();
            break;
         case MY_OPENPOS:
            if(OrderType() == OP_BUY) lots += OrderLots();
            if(OrderType() == OP_SELL) lots -= OrderLots();
            break;
         case MY_LIMITPOS:
            if(OrderType() == OP_BUYLIMIT) lots += OrderLots();
            if(OrderType() == OP_SELLLIMIT) lots -= OrderLots();
            break;
         case MY_STOPPOS:
            if(OrderType() == OP_BUYSTOP) lots += OrderLots();
            if(OrderType() == OP_SELLSTOP) lots -= OrderLots();
            break;
         case MY_PENDPOS:
            if(OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP) lots += OrderLots();
            if(OrderType() == OP_SELLLIMIT || OrderType() == OP_SELLSTOP) lots -= OrderLots();
            break;
         case MY_BUYPOS:
            if(OrderType() == OP_BUY || OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP) lots += OrderLots();
            break;
         case MY_SELLPOS:
            if(OrderType() == OP_SELL || OrderType() == OP_SELLLIMIT || OrderType() == OP_SELLSTOP) lots -= OrderLots();
            break;
         case MY_ALLPOS:
            if(OrderType() == OP_BUY || OrderType() == OP_BUYLIMIT || OrderType() == OP_BUYSTOP) lots += OrderLots();
            if(OrderType() == OP_SELL || OrderType() == OP_SELLLIMIT || OrderType() == OP_SELLSTOP) lots -= OrderLots();
            break;
         default:
            Print("[CurrentOrdersError] : Illegel order type("+type+")");
            break;
      }
      if(lots != 0) break;
   }
   return(lots);
}

// 注文を送信する
bool MyOrderSend(int type, double lots, double price, int slippage, double sl, double tp, string comment, int magic)
{
   price = NormalizeDouble(price, Digits);
   sl = NormalizeDouble(sl, Digits);
   tp = NormalizeDouble(tp, Digits);
 
   int starttime = GetTickCount();
   while(true)
   {
      if(GetTickCount() - starttime > MyOrderWaitingTime*1000)
      {
         Alert("OrderSend timeout. Check the experts log.");
         return(false);
      }
      if(IsTradeAllowed() == true)
      {
         RefreshRates();
         if(OrderSend(Symbol(), type, lots, price, slippage, sl, tp, comment, magic, 0, ArrowColor[type]) != -1) return(true);
         int err = GetLastError();
         Print("[OrderSendError] : ", err, " ", ErrorDescription(err));
         if(err == ERR_INVALID_PRICE) break;
         if(err == ERR_INVALID_STOPS) break;
      }
      Sleep(100);
   }
   return(false);
}

// オープンポジションを変更する
bool MyOrderModify(double sl, double tp, int magic)
{
   int ticket = 0;
   for(int i=0; i<OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS) == false) break;
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != magic) continue;
      int type = OrderType();
      if(type == OP_BUY || type == OP_SELL)
      {
         ticket = OrderTicket();
         break;
      }
   }
   if(ticket == 0) return(false);

   sl = NormalizeDouble(sl, Digits);
   tp = NormalizeDouble(tp, Digits);

   if(sl == 0) sl = OrderStopLoss();
   if(tp == 0) tp = OrderTakeProfit();

   if(OrderStopLoss() == sl && OrderTakeProfit() == tp) return(false);

   int starttime = GetTickCount();
   while(true)
   {
      if(GetTickCount() - starttime > MyOrderWaitingTime*1000)
      {
         Alert("OrderModify timeout. Check the experts log.");
         return(false);
      }
      if(IsTradeAllowed() == true)
      {
         if(OrderModify(ticket, 0, sl, tp, 0, ArrowColor[type]) == true) return(true);
         int err = GetLastError();
         Print("[OrderModifyError] : ", err, " ", ErrorDescription(err));
         if(err == ERR_NO_RESULT) break;
         if(err == ERR_INVALID_STOPS) break;
      }
      Sleep(100);
   }
   return(false);
}

// オープンポジションを決済する
bool MyOrderClose(int slippage, int magic)
{
   int ticket = 0;
   for(int i=0; i<OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS) == false) break;
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != magic) continue;
      int type = OrderType();
      if(type == OP_BUY || type == OP_SELL)
      {
         ticket = OrderTicket();
         break;
      }
   }
   if(ticket == 0) return(false);

   int starttime = GetTickCount();
   while(true)
   {
      if(GetTickCount() - starttime > MyOrderWaitingTime*1000)
      {
         Alert("OrderClose timeout. Check the experts log.");
         return(false);
      }
      if(IsTradeAllowed() == true)
      {
         RefreshRates();
         if(OrderClose(ticket, OrderLots(), OrderClosePrice(), slippage, ArrowColor[type]) == true) return(true);
         int err = GetLastError();
         Print("[OrderCloseError] : ", err, " ", ErrorDescription(err));
         if(err == ERR_INVALID_PRICE) break;
      }
      Sleep(100);
   }
   return(false);
}

// 待機注文をキャンセルする
bool MyOrderDelete(int magic)
{
   int ticket = 0;
   for(int i=0; i<OrdersTotal(); i++)
   {
      if(OrderSelect(i, SELECT_BY_POS) == false) break;
      if(OrderSymbol() != Symbol() || OrderMagicNumber() != magic) continue;
      int type = OrderType();
      if(type != OP_BUY && type != OP_SELL)
      {
         ticket = OrderTicket();
         break;
      }
   }
   if(ticket == 0) return(false);

   int starttime = GetTickCount();
   while(true)
   {
      if(GetTickCount() - starttime > MyOrderWaitingTime*1000)
      {
         Alert("OrderDelete timeout. Check the experts log.");
         return(false);
      }
      if(IsTradeAllowed() == true)
      {
         if(OrderDelete(ticket) == true) return(true);
         int err = GetLastError();
         Print("[OrderDeleteError] : ", err, " ", ErrorDescription(err));
      }
      Sleep(100);
   }
   return(false);
}
