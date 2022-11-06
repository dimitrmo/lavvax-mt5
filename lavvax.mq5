//+------------------------------------------------------------------+
//|                                                       lavvax.mq5 |
//|                                      Copyright 2022, Anadyme Ltd |
//|                                          https://www.anadyme.com |
//+------------------------------------------------------------------+

#property copyright "Copyright 2022, Anadyme Ltd"
#property link      "https://www.anadyme.com"
#property version   "1.12"
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
   int result = pub.SendHistorical(1);
   // Print(">> historical send result ", result);
   if (result < 0) {
      Print(">> reconnecting due to previous negative result ", result);
      result = pub.Disconnect();
      Print(">> disconnect result ", result);
      result = pub.Connect();
      Print(">> reconnect result ", result);
      Sleep(1000);
      OnTick();
      return;
   }
   
   result = pub.SendTick();
   // Print(">> sending ticks result ", result);
   if (result < 0) {
      Print(">> reconnecting due to previous negative result ", result);
      result = pub.Disconnect();
      Print(">> disconnect result ", result);
      result = pub.Connect();
      Print(">> reconnect result ", result);
      Sleep(1000);
      OnTick();
   }
  }

//+------------------------------------------------------------------+
//| Expert ticker                                                    |
//+------------------------------------------------------------------+
void OnTimer(void)
  {
    int result = pub.SendPing();
    Print(">> ping result ", result);
    if (result < 0) {
       Print(">> reconnecting due to previous negative result ", result);
       result = pub.Disconnect();
       Print(">> disconnect result ", result);
       result = pub.Connect();
       Print(">> reconnect result ", result);
       Sleep(1000);
    }
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
