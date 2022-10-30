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

input string hostname = "b85b0a17eb9c.apps.anadyme.com"; // Connect hostname.

input LavvaxGatewayProtocol protocol = WebSocket; // Connection protocol.

input int history_size = 30;  // Last 30 history entries

//+------------------------------------------------------------------+
//| Global variables                                                 |
//+------------------------------------------------------------------+

LavvaxGatewayPublisher *pub;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
   EventSetTimer(15);
   
   pub = new LavvaxGatewayPublisher(hostname, protocol, history_size);
   
   int result = pub.Connect();
   Print(">> connection result ", result);
   
   for(int i = history_size; i>=1; i--)
    {
        result = pub.SendHistorical(i);
        Print(">> historical result[", i, "] ", result);
    }
   
   OnTick();
   
   return(INIT_SUCCEEDED);
  }

//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   MT5HistoricalPosition pos1 = pub.GetHistoricalAt(1);
   MT5Tick tick = pub.PrepareTick();
   
   if (pos1.time == tick.time) {
      int result = pub.SendHistorical(1);
      Print(">> historical send result ", result);
   }
   
   int written = pub.SendTick();
   Print(">> sending ticks result ", written);
  }

//+------------------------------------------------------------------+
//| Expert ticker                                                    |
//+------------------------------------------------------------------+
void OnTimer(void)
  {
    int result = pub.SendPing();
    Print(">> ping result ", result);
  }

//+------------------------------------------------------------------+
//| Expert de-initialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   EventKillTimer();
   Print(">> deinit reason ", reason);
   int result = pub.Disconnect();
   Print(">> disconnect result ", result);
  }
//+------------------------------------------------------------------+
