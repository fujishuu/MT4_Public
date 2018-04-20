//+------------------------------------------------------------------+
//|                                                              mq4 |
//|                                                        sji_fujii |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "sji_fujii"
#property link      ""
#property version   "1.00"
#property strict

int ArrayPuchBack(string& symbols[], string symbol)
{
	int len=ArraySize(symbols);
	ArrayResize(symbols,len+1);
	symbols[len]=symbol;
	return(len+1);
}

int ArrayPuchBackDouble(double& vals[], double val)
{
	int len=ArraySize(vals);
	ArrayResize(vals,len+1);
	vals[len]=val;
	return(len+1);
}

string OrderTypeToStr(int otype)
{
	string str;
	
	switch(otype)
	{
	case 0:
		str="OP_BUY";
		break;
	case 1:
		str="OP_SELL";
		break;
	case 2:
		str="OP_BUYLIMIT";
		break;
	case 3:
		str="OP_BUYSTOP";
		break;
	case 4:
		str="OP_SELLLIMIT";
		break;
	case 5:
		str="OP_SELLSTOP";
		break;
	default:
		str="error";
	}
	return(str);
}

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
   string symbolA[100],symbolB[];
	int ototal=OrdersTotal();
	ArrayResize(symbolA,ototal);

	for(int a=0; a<ototal; a++)
	{
		if(!OrderSelect(a,SELECT_BY_POS)) break;
		symbolA[a] = OrderSymbol();
	}

	for(int a=0; a<ototal; a++)
	{
		if(a==0) 
			{ArrayPuchBack(symbolB,symbolA[a]); continue;}
		int sig=0;
		int len = ArraySize(symbolB);
		for(int b=0; b<len; b++)
		{
			if(symbolA[a]==symbolB[b]) sig++;
		}
		if(sig==0) ArrayPuchBack(symbolB,symbolA[a]);
	}

	int sizeB = ArraySize(symbolB);
	string info1="";	
	for(int a=0; a<sizeB; a++)
	{
		info1 += symbolB[a] + "\n";
		for(int b=0; b<ototal; b++)
		{
			if(!OrderSelect(b,SELECT_BY_POS)) break;
			if(OrderSymbol()==symbolB[a]) 
			{
            if( OrderType()==0)
            {
   				info1 += IntegerToString(OrderMagicNumber())+"\t"+OrderTypeToStr(OrderType())+"\t"+(string)OrderLots()+"\t" + (string)OrderOpenPrice()+"\t"+(string)Bid+"\t"+(string)OrderProfit()+"\t"+
   				TimeToStr(OrderOpenTime(),TIME_DATE|TIME_SECONDS)  +"\n";
            }
            if( OrderType()==1)
            {
   				info1 += IntegerToString(OrderMagicNumber())+"\t"+OrderTypeToStr(OrderType())+"\t"+(string)OrderLots()+"\t" + (string)OrderOpenPrice()+"\t"+(string)Ask+"\t"+(string)OrderProfit()+"\t"+
   				TimeToStr(OrderOpenTime(),TIME_DATE|TIME_SECONDS)  +"\n";
            }            
			}

		}
		info1 += "\n";
	}   
   
   int handle = FileOpen("snapshot.txt", FILE_WRITE);
   FileWrite(handle, info1);
   FileClose(handle);
  }
//+------------------------------------------------------------------+
