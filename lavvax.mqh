//+------------------------------------------------------------------+
//|                                                       lavvax.mqh |
//|                                      Copyright 2022, Anadyme Ltd |
//|                                          https://www.anadyme.com |
//+------------------------------------------------------------------+

#property copyright "Copyright 2022, Anadyme Ltd"
#property link      "https://www.anadyme.com"
#property version   "1.11"
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
    int        digits;
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
    int        digits;
};

enum LavvaxGatewayProtocol {
   HTTP = 1,
   WebSocket = 2,
   MQTT = 4
};

#import "lavvax_metatrader.dll"
   int gw_connect(uchar&[], int, int);
   int gw_disconnect(int);
   int gw_send_ping(int);
   int gw_send_tick(int, uchar&[], int, MT5Tick&);
   int gw_send_historical(int, uchar&[], int, MT5HistoricalPosition&);
#import

class LavvaxGatewayPublisher {
public:
   void LavvaxGatewayPublisher(string, LavvaxGatewayProtocol, int);
   int Connect();
   int Disconnect();
   int SendPing();
   int SendTick();
   MT5Tick PrepareTick();
   int SendHistorical(int);   
   MT5HistoricalPosition GetHistoricalAt(int);
private:
   int      m_conn_x;

   string   m_hostname;
   char     m_hostname_raw[];
   int      m_hostname_len;

   int      m_history_size;
   int      m_period;
   
   LavvaxGatewayProtocol   m_protocol;
   
   string   m_symbol;
   char     m_symbol_raw[];
   int      m_symbol_len;
   
   MqlTick               m_last_tick;
   MT5HistoricalPosition m_last_historical;
};

void LavvaxGatewayPublisher::LavvaxGatewayPublisher(string hn, LavvaxGatewayProtocol proto, int hs) {   
   m_history_size = hs;
   m_period = Period();
   
   m_hostname = hn;
   m_hostname_len = StringLen(m_hostname);
   StringToCharArray(m_hostname, m_hostname_raw, 0, m_hostname_len, CP_UTF8);
   
   m_protocol = proto;
   
   m_symbol = Symbol();
   m_symbol_len = StringLen(m_symbol);
   StringToCharArray(m_symbol, m_symbol_raw, 0, m_symbol_len, CP_UTF8);
   
   SymbolInfoTick(m_symbol, m_last_tick);
   m_last_historical = GetHistoricalAt(1);
}

int LavvaxGatewayPublisher::Connect() {
   m_conn_x = gw_connect(m_hostname_raw, m_hostname_len, m_protocol);
   return m_conn_x;
}

int LavvaxGatewayPublisher::Disconnect() {
   return gw_disconnect(m_conn_x);
}

int LavvaxGatewayPublisher::SendPing() {
   return gw_send_ping(m_conn_x);
}

int LavvaxGatewayPublisher::SendTick() {
    if (SymbolInfoTick(m_symbol, m_last_tick)) {
        MT5Tick t = PrepareTick();
        return gw_send_tick(m_conn_x, m_symbol_raw, m_symbol_len, t);
    }

    return -1;
}

MT5Tick LavvaxGatewayPublisher::PrepareTick() {
   MT5Tick t = {
      m_last_tick.time,
      m_last_tick.bid,
      m_last_tick.ask,
      m_last_tick.last,
      m_last_tick.volume,
      m_last_tick.time_msc,
      m_last_tick.flags,
      m_last_tick.volume_real,
      Digits(),
   };
   
   return t;
}

MT5HistoricalPosition LavvaxGatewayPublisher::GetHistoricalAt(int shift) {
    MT5HistoricalPosition h = {
        m_period,
        iBars(m_symbol, PERIOD_CURRENT),
        iClose(m_symbol, PERIOD_CURRENT, shift),
        iHigh(m_symbol, PERIOD_CURRENT, shift),
        iLow(m_symbol, PERIOD_CURRENT, shift),
        iOpen(m_symbol, PERIOD_CURRENT, shift),
        iTime(m_symbol, PERIOD_CURRENT, shift),
        iVolume(m_symbol, PERIOD_CURRENT, shift),
        Digits(),
    };
    
    return h;
}

int LavvaxGatewayPublisher::SendHistorical(int shift) {
    m_last_historical = GetHistoricalAt(shift);
    return gw_send_historical(m_conn_x, m_symbol_raw, m_symbol_len, m_last_historical);
}
