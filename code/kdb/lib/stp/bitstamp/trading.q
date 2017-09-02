.util.Load `:lib/stp/bitstamp/common.q;

SendOrder:{[ORDER]
  sym:{ (3#x),"/",-3#x } string ORDER[`Symbol]; // add "/"
  // build message
  msg:map(11h;ORDER[`ClientOrderID];            // ClOrdId
          55h;sym ;                             // Symbol
          54h;toFixSide ORDER[`Side];           // Side
          60h;.z.p;                             // TransactTime
          38h;ORDER[`Quantity];                 // Quantity
          40h;toFixOrderType ORDER[`OrderType]; // OrdType
          44h;ORDER[`Price];                    // Price
          59h;"1");                             // TimeInForce = 1 = GTC
  // send message
  Send.NEW_ORDER_SINGLE msg
  };

CancelOrder:{[CANCEL]
  msg:map(11h;ORDER[`ClientOrderID];            // ClOrdId
          41h;ORDER[`OriginalClientOrderID];    // ClOrdIdOrderQty
          37h;ORDER[`OrderID`];                 // OrderId
          60h;.z.p);                            // TransactTime

  Send.ORDER_CANCEL_REQUEST msg
  };

/'0' - New
/'4' - Canceled
/'8' - Rejected
/'F' - Trade (partial fill or fill)
/ 11 37 41 17 150 39 55 54 40 32 31 151 14 6 60

On.EXECUTION_REPORT:{[ER]
  msg:map();

  execType:ER 150h;

  msg[`ClientOrderID]:`$ER 11h;
  msg[`OrderID]:`$ER 37h;
  msg[`ExecutionID]:`$ER 17h;
  msg[`Side]:fromFixSide ER 54h;

  if["0"~execType;
    // accept
    msg[`Status]:`Accepted;

    :();
    ];

  if["F"~execType;
    // fill (partial or full)
    ff:(cumQty:"F"$ER 14h)~orderQty:"F"$ER 38h;
    msg[`Status]:$[ff;`Filled;`PartiallyFilled];
    msg[`Quantity]:orderQty;
    msg[`LastQty]:"F"$ER 32;
    msg[`LastPrice]:"F"$ER 31;
    msg[`Filled]:cumQty;
    :();
    ];

  if["4"~execType;
    // cancelled
    msg[`Status]:`Cancelled;                    // note two l's in cancelled
    :();
    ];

  if["8"~execType;
    // rejected
    :();
    ];

  //
  .log.Err ("Unexpected EXECUTION_TYPE received";execType);

  };

On.