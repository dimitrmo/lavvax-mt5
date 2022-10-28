//+------------------------------------------------------------------+
//|                                                       lavvax.mqh |
//|                                      Copyright 2022, Anadyme Ltd |
//|                                          https://www.anadyme.com |
//+------------------------------------------------------------------+

#property copyright "Copyright 2022, Anadyme Ltd"
#property link      "https://www.anadyme.com"
#property version   "1.10"
#property strict

struct MT5Tick {
    datetime   time;
    double     bid;
    double     ask;
    double     last;
    ulong      volume;
    long       time_msc;
    uint       flags;
    double     volume_real;
};

struct MT5HistoricalPosition {
    int        period;
    int        bars;
    double     close;
    double     high;
    double     low;
    double     open;
    datetime   time;
    long       volume;
};    

#import "lavvax_metatrader.dll"
   int gw_connect(uchar&[], int);
   int gw_send_tick(uchar&[], int, MT5Tick &t);
   int gw_send_historical(uchar&[], int, MT5HistoricalPosition &h);
#import

class LavvaxGatewayPublisher {
public:
   void LavvaxGatewayPublisher(string, int);
   int Connect();
   int SendTick();
   int SendHistorical(int);
private:
   string   m_endpoint;
   char     m_endpoint_raw[];
   int      m_endpoint_len;

   int      m_history_size;
   int      m_period;
   
   string   m_symbol;
   char     m_symbol_raw[];
   int      m_symbol_len;
   
   MqlTick  m_last_tick;
};

void LavvaxGatewayPublisher::LavvaxGatewayPublisher(string ep, int hs) {
   m_endpoint = ep;
   StringToCharArray(m_endpoint, m_endpoint_raw);
   m_endpoint_len = ArraySize(m_endpoint_raw);   
   m_history_size = hs;
   m_period = Period();   
   m_symbol = Symbol();
   StringToCharArray(m_symbol, m_symbol_raw);
   m_symbol_len = ArraySize(m_symbol_raw);
}

int LavvaxGatewayPublisher::Connect() {
   return gw_connect(m_endpoint_raw, m_endpoint_len);
}

int LavvaxGatewayPublisher::SendTick() {
    if (SymbolInfoTick(m_symbol, m_last_tick)) {        
        MT5Tick t = {
            m_last_tick.time,
            m_last_tick.bid,
            m_last_tick.ask,
            m_last_tick.last,
            m_last_tick.volume,
            m_last_tick.time_msc,
            m_last_tick.flags,
            m_last_tick.volume_real
        };

        return gw_send_tick(m_symbol_raw, m_symbol_len, t);
    }

    return -1;
}

int LavvaxGatewayPublisher::SendHistorical(int shift) {
    MT5HistoricalPosition h = {
        m_period,
        iBars(m_symbol, PERIOD_CURRENT),
        iClose(m_symbol, PERIOD_CURRENT, shift),
        iHigh(m_symbol, PERIOD_CURRENT, shift),
        iLow(m_symbol, PERIOD_CURRENT, shift),
        iOpen(m_symbol, PERIOD_CURRENT, shift),
        iTime(m_symbol, PERIOD_CURRENT, shift),
        iVolume(m_symbol, PERIOD_CURRENT, shift),
    };

    return gw_send_historical(m_symbol_raw, m_symbol_len, h);
}