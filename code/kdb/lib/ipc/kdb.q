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
  if[H in subscribers;
    subscribers::subscribers except H;   // remove subscriber
    :()
    ];
  if[H in exec handle from connections;
    connections::update connected:0b,handle:0Ni from connections where handle=H;
    :()
    ];
  };

trySubscribe:{[S]
  h:@[hopen;S;0Ni];                    // open handle to S(erver)
  if[null h;
    :(0Ni;0b);                         // connection failed
    ];
  if[@[h;(`.ipc.sub;`);0b];            // call subscribe
    :(h;1b);                           // connection suceeded
    ];
  @[hclose;h;0b];                      // close handle
  :(0Ni;0b);                           // connection *was* successful, but failed to subscribe
  };

subscribe:{[S]                         // called by clients
  res:trySubscribe S;
  .ipc.connections[`$string S]:(res);  // update connections table
  last res                             // return success
  };

reconnect:{[]
  {
    res:.ipc.subscribe x;
    .log.Inf ("Reconnect to";x;"was";$[res;"successful";"unsuccessful"])
  } each exec server from .ipc.connections where not connected
  };

\d .

.timer.Add[`.ipc.reconnect;0D00:00:03]; // attempt to reconnect every 3 seconds