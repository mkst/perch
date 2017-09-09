.util.Load `:lib/timer/timer.q;

\d .ipc

subscribers:();
connections: `server xkey flip `server`handle`connected!"sib"$\:();

pub:{[MSG]
  { neg[x]y;                           // async send
    neg[x][]                           // flush socket
  }[;`.u.upd,MSG] each subscribers;
  };

sub:{[]                                // TODO restrict subscription to sym/exch
  subscribers,::.z.w;                  // add subcriber
  1b                                   // return true
  };

.z.pc:{[H]
  .log.Inf (`.z.pc;H);
  if[H in subscribers;
    subscribers::subscribers except H;   // remove subscriber
    :()
    ];
  if[H in exec handle from connections;
    connections::update connected:0b,handle:0Ni from connections where handle=H;
    :()
    ];
  };

subscribe:{[S]                         // called by clients
  h:@[hopen;S;0Ni];                    // open handle to S(erver)
  if[not null h;                       // check handle is not null
    if[@[h;(`.ipc.sub;`);0b];          // call subscribe
      connections[`$string S]:(h;1b);  // mark connection as connected
      :1b;                             // return true
      ];
    ];
    :0b;                               // return false
  };

\d .