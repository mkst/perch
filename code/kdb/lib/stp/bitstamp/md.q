.util.Load `:lib/stp/bitstamp/common.q;

snapshot:{[SNAP]
  price:"F"$SNAP 270h;                          / MDEntryPx (cast price to float)
  qty:"F"$SNAP 271h;                            / MDEntrySize (cast to float)
  side:"BS""H"$SNAP 269h;                       / MDEntryType 0 = B = Bid, 1 = S = Offer
  `side`price`qty!(side;price;qty)             / return side, price, qty
  };

increment:{[INCR]
  sym:`$INCR[55h] 0 1 2 4 5 6;                  / remove "/"
  id:"J"$INCR 278h;                             / MDEntryID
  price:"F"$INCR 270h;                          / MDEntryPx
  qty:"F"$INCR 271h;                            / MDEntrySize
  date:INCR 272h;                               / MDEntryDate
  time:INCR 273h;                               / MDEntryTime
  datetime:"P"$date," ",time;                   / cast date and time to datetime
  `timeExch`sym`side`price`qty`id!(datetime;sym;"X";price;qty;id)
  };

/ used for pricebook
On.MARKET_DATA_SNAPSHOT:{[MSG]
  .last.MDS:MSG;
  .log.Inf "MARKET_DATA_SNAPSHOT";
  t:.timer.GetTimestamp[];
  symbol:`$MSG[55h] 0 1 2 4 5 6;               / remove "/"
  quotes:update time:t, timeExch:"P"$MSG 52h,  / add time as SendingTime
         sym:symbol,                           / symbol is outside the rpt group
         exch:EXCH,                            / exchange
         action:"N",                           / action is NEW
         snapshot:1b from snapshot each .fix.split[MSG;269h];
  .ipc.pub (`Quote;quotes)
  };

/ used for trade notification
On.MARKET_DATA_INCREMENT:{[MSG]
  .last.MDI:MSG;
  .log.Inf "MARKET_DATA_INCREMENT";
  t:.timer.GetTimestamp[];
  trades:update time:t,exch:EXCH from increment each .fix.split[MSG;279h];
  .ipc.pub (`Trade;trades)
  };

On.MARKET_DATA_REQUEST_REJECT:{[MSG]
  .log.Wrn "MARKET_DATA_REQUEST_REJECT";
  symbol:`$MSG[55h] 0 1 2 4 5 6;
  .fix.Subscriptions[symbol]:0b;
  };

Subscribe:{[SYMBOL]
  .fix.Subscriptions[SYMBOL]:1b;
  symbol:string SYMBOL;
  msg:map(262h;symbol;                         /MDReqID
          263h;1;                              /SubscriptionRequestType = 1, Subscribe
          264h;0;                              /MarketDepth = 0, Full Book
          267h;3;                              /NoMDEntryTypes = 3
          269h;0;                              /MDEntryType = 0 = Bid
          269h;1;                              /MDEntryType = 1 = Offer
          269h;2;                              /MDEntryType = 2 = Trade
          146h;1;                              /NoRelatedSym = 1
          55h;{x[0 1 2],"/",x[3 4 5]} symbol); /Symbol = symbol
  Send.MARKET_DATA_REQUEST msg
  };
