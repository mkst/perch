.util.Load `:lib/cfg/cfg.q;            / for .cfg
.util.Load `:lib/ipc/kdb.q;            / for pub/sub
.util.Load `:lib/timer/timer.q;        / for GetTimestamp[]
.util.Load `:lib/schema/book.q;        / for book schema

schema:`side`price xkey flip `side`price`qty`time!"cffp"$\:(); / quote schema
lastquote:()!();

processQuote:{[SYM;EXCH;QUOTE]
  .last.quote:QUOTE;
  .last.lastquote:lastquote[EXCH;SYM];
  action:QUOTE[`action];
  qty:QUOTE[`qty];
  lastqty:exec first qty from lastquote[EXCH;SYM];
  $["N"=action;
    lastquote[EXCH;SYM],:`side`price`qty`time!(QUOTE[`side];QUOTE[`price];qty+0^lastqty;QUOTE[`time]);   / add new entry
    "D"=action;
      $[(qty^lastqty)=qty;
        lastquote[EXCH;SYM]:delete from lastquote[EXCH;SYM] where side=QUOTE[`side],price=QUOTE[`price]; / delete whole entry
        lastquote[EXCH;SYM]:update qty:lastqty-qty, time:QUOTE[`time] from lastquote[EXCH;SYM] where side=QUOTE[`side],price=QUOTE[`price] / update entry
      ];
      lastquote[EXCH;SYM]:update qty:qty,time:QUOTE[`time] from lastquote[EXCH;SYM] where side=QUOTE[`side],price=QUOTE[`price] / pure update
    ];
  };

processQuotes:{[QUOTES]
  .last.quotes:QUOTES;
  snapshot:exec first snapshot from QUOTES;
  sym:exec first sym from QUOTES;
  exch:exec first exch from QUOTES;
  if[not exch in key lastquote;
    .log.Inf ("initialising lastquote for";exch);
    lastquote[exch]:()!()
    ];
  if[not sym in key lastquote[exch]; /TODO: speed this up with LUT
    lastquote[exch;sym]:schema
  ];
  if[snapshot;
    lastquote[exch;sym]:schema         /clear book
    ];
  processQuote[sym;exch;] each (),delete sym,exch,snapshot from QUOTES;
  / build bids and asks
  bids:enlist exec bidpx:price, bidqty:qty, bidtime:time from lastquote[exch;sym] where side="S";
  asks:enlist exec askpx:price, askqty:qty, asktime:time from lastquote[exch;sym] where side="B";
  / publish book for sym;exch
  .ipc.pub(`Book;`time`sym`exch xcols update time:.timer.GetTimestamp[], sym:sym, exch:exch from bids,'asks)
  };

.u.upd:{[TABLE;DATA]
  if[not `Quote=TABLE; / FIXME: only subscribe to Quote updates?
    :()
    ];
  processQuotes each (where differ DATA[`sym`exch]) cut DATA / ?
  };

init:{[ARGS]
  opts::.Q.opt ARGS;
  if[not `config in key opts;
    .log.Err "bookbuilder_init.q -config <path/to/config.cfg>";
    exit 1
  ];
  .cfg.LoadConfig `$":",first opts`config;
  system "p ",.cfg.Config.ListenPort;
  .ipc.subscribe each "J"$ "," vs .cfg.Config.Subscriptions;
  };

if[`bookbuilder_init.q=last `$"/" vs string .z.f;init[.z.x]];