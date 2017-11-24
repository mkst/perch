.util.Load `:lib/cfg/cfg.q;            / for .cfg
.util.Load `:lib/ipc/kdb.q;            / for pub/sub
.util.Load `:lib/timer/timer.q;        / for GetTimestamp[]
.util.Load `:lib/schema/book.q;        / for book schema
.util.Load `:lib/schema/bbo.q;         / for BBO schema

schema:`side`price xkey flip `side`price`qty`time!"cffp"$\:();      / quote schema
bboschema:`bidpx`bidqty`bidtime`askpx`askqty`asktime!"ffpffp"$\:(); / internal BBO schema
lastquote:()!();
lastbbo:()!();

processQuote:{[SYM;EXCH;QUOTE]
  .last.quote:QUOTE;
  /==========================================================
  action:QUOTE[`action];
  qqty:QUOTE[`qty];
  qprice:QUOTE[`price];
  qside:QUOTE[`side];
  qtime:QUOTE[`time];
  /==========================================================
  lastqty:exec first qty from lastquote[EXCH;SYM] where price=qprice,side=qside;                             / cannot rely on uncrossed book
  /==========================================================
  $["N"=action;
    lastquote[EXCH;SYM],:`side`price`qty`time!(qside;qprice;qqty+0^lastqty;qtime);                           / add new entry
    "D"=action;
      $[(qqty^lastqty)=qqty;
        lastquote[EXCH;SYM]:delete from lastquote[EXCH;SYM] where side=qside,price=qprice;                   / delete whole entry
        lastquote[EXCH;SYM],:`side`price`qty`time!(qside;qprice;lastqty-qqty;qtime)                          / update entry
      ];
      lastquote[EXCH;SYM]:update qty:qqty,time:qtime from lastquote[EXCH;SYM] where side=qside,price=qprice  / pure update
    ]
  };

processQuotes:{[QUOTES]
  .last.quotes:QUOTES;
  snapshot:exec first snapshot from QUOTES;
  sym:exec first sym from QUOTES;
  exch:exec first exch from QUOTES;
  qtime:exec first time from QUOTES;
  /==========================================================
  if[not exch in key lastquote;
    lastquote[exch]:()!();
    lastbbo[exch]:()!()
    ];
  if[not sym in key lastquote[exch];  / TODO: speed this up with LUT ?
    lastquote[exch;sym]:schema;
    lastbbo[exch;sym]:2#0f
    ];
  if[snapshot;
    lastquote[exch;sym]:schema;        / clear book on snapshot
    ];
  /==========================================================
  processQuote[sym;exch;] each (),QUOTES;
  /==========================================================
  bids:enlist `bidpx`bidqty`bidtime!b[;idesc first b:exec (price;qty;time) from lastquote[exch;sym] where side="B"]; / build bids
  asks:enlist `askpx`askqty`asktime!a[;iasc  first a:exec (price;qty;time) from lastquote[exch;sym] where side="S"]; / build asks
  .last.bids:bids;
  .last.asks:asks;
  /==========================================================
  now:.timer.GetTimestamp[];
  / publish book for sym;exch
  .ipc.pub(`Book;`time`sym`exch xcols update time:now, timeExch:qtime, sym:sym, exch:exch from bids,'asks);
  / check BBO and publish
  if[not lastbbo[sym;exch]~bbo:(first b:first flip first .last.bids),(first a:first flip first .last.asks);
      lastbbo[sym;exch]:bbo;
       .ipc.pub(`BBO;`time`sym`exch xcols update time:now, timeExch:qtime, sym:sym, exch:exch from enlist a,b)
    ];
  };

.u.upd:{[TABLE;DATA]
  if[not `Quote=TABLE; / TODO: only subscribe to Quote updates?
    :()
    ];
  processQuotes each (where differ DATA[`time]) cut DATA / cut only required for backtesting
  };

init:{[ARGS]
  opts::.Q.opt ARGS;
  if[not `config in key opts;
    .log.Err "bookbuilder_init.q -config <path/to/config.cfg>";
    exit 1
  ];
  .cfg.LoadConfig `$":",first opts`config;
  system "p ",.cfg.Config.ListenPort;
  .ipc.subscribe each `$ "," vs .cfg.Config.Subscriptions;
  };

if[`bookbuilder_init.q=last `$"/" vs string .z.f;init[.z.x]];