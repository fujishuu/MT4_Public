//+------------------------------------------------------------------+
//|                                                        MyLib.mqh |
//|                                   Copyright (c) 2009, Toyolab FX |
//|                                         http://forex.toyolab.com |
//+------------------------------------------------------------------+
#property copyright "Copyright (c) 2009, Toyolab FX"
#property link      "http://forex.toyolab.com"

#include <stderror.mqh>
#include <stdlib.mqh>

#define MY_OPENPOS   6
#define MY_LIMITPOS  7
#define MY_STOPPOS   8
#define MY_PENDPOS   9
#define MY_BUYPOS   10
#define MY_SELLPOS  11
#define MY_ALLPOS   12

#import "MyLib.ex4"
// ���݂̃|�W�V�����̃��b�g���i�{�F���� �|�F����j
double MyCurrentOrders(int type, int magic);
// �����𑗐M����
bool MyOrderSend(int type, double lots, double price, int slippage, double sl, double tp, string comment, int magic);
// �I�[�v���|�W�V������ύX����
bool MyOrderModify(double sl, double tp, int magic);
// �I�[�v���|�W�V���������ς���
bool MyOrderClose(int slippage, int magic);
// �ҋ@�������L�����Z������
bool MyOrderDelete(int magic);
#import
