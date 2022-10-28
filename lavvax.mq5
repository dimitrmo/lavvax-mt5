//+------------------------------------------------------------------+
//|                                                       lavvax.mq5 |
//|                                      Copyright 2022, Anadyme Ltd |
//|                                          https://www.anadyme.com |
//+------------------------------------------------------------------+

#property copyright "Copyright 2022, Anadyme Ltd"
#property link      "https://www.anadyme.com"
#property version   "1.10"
#property strict

#include "lavvax.mqh"

//+------------------------------------------------------------------+
//| Inputs                                                           |
//+------------------------------------------------------------------+

input string endpoint;

input int history_size = 30;  // last 30 entries

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+

LavvaxGatewayPublisher *pub;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   EventSetTimer(30);
   pub = new LavvaxGatewayPublisher(endpoint, history_size);
   OnTick();
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   int written = pub.SendTick();
   Print("tick written=", written);
   written = pub.SendHistorical(0);
   Print("historical=", written);
  }

//+------------------------------------------------------------------+
//| Expert de-initialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
  }
//+------------------------------------------------------------------+
