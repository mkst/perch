.util.Load `:lib/stp/bitstamp/common.q;

snapshot:{[SNAP]
  price:"F"$SNAP`270;                          / MDEntryPx (cast price to float)
  qty:"F"$SNAP`271;                            / MDEntrySize (cast to float)
  side:"BS""H"$SNAP`269;                       / MDEntryType 0 = B = Bid, 1 = S = Offer
  `side`price`qty!(side;price;qty)             / return side, price, qty
  };

increment:{[INCR]
  sym:INCR`55;                                 / Symbol
  id:INCR`278;                                 / MDEntryID
  price:INCR`270;                              / MDEntryPx
  qty:INCR`271;                                / MDEntrySize
  date:INCR`272;                               / MDEntryDate
  time:INCR`273;                               / MDEntryTime
  datetime:"P"$date," ",time;                  / cast date and time to datetime
  `timeExch`sym`side`price`qty`id!(datetime;sym;"X";price;qty;id)
  };

/ used for pricebook
On.MARKET_DATA_SNAPSHOT:{[MSG]
  .log.Inf "MARKET_DATA_SNAPSHOT";
  t:.timer.GetTimestamp[];
  sym:MSG[`55] 0 1 2 4 5 6;                    / remove "/"
  quotes:update time:t, timeExch:"P"MSG`52,    / add time as SendingTime
         symbol:sym,                           / symbol is outside the rpt group
         exch:EXCH,                            / exchange
         snapshot:1b from snapshot each .fix.split[MSG;`269];
  pub[`Quote;quotes];
  };

/ used for trade notification
On.MARKET_DATA_INCREMENT:{[MSG]
  .log.Inf "MARKET_DATA_INCREMENT";
  t:.timer.GetTimestamp[];
  trades:update time:t,exch:EXCH from increment each .fix.split[MSG;`279];
  pub[`Trade;trades];
  };

On.MARKET_DATA_REQUEST_REJECT:{[MSG]
  .log.Inf "MARKET_DATA_REQUEST_REJECT"
  };

Subscribe:{[SYMBOL]
  symbol:string SYMBOL;
  msg:map(`262;symbol;                         /MDReqID
          `263;1;                              /SubscriptionRequestType = 1, Subscribe
          `264;0;                              /MarketDepth = 0, Full Book
          `267;3;                              /NoMDEntryTypes = 3
          `269;0;                              /MDEntryType = 0 = Bid
          `269;1;                              /MDEntryType = 1 = Offer
          `269;2;                              /MDEntryType = 2 = Trade
          `146;1;                              /NoRelatedSym = 1
          `55;{x[0 1 2],"/",x[3 4 5]} symbol); /Symbol = symbol
  Send.MARKET_DATA_REQUEST msg
  };
