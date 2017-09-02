\d .ipc

subscribers:();

pub:{[MSG]
  { neg[x]y;                           // async send
    neg[x][]                           // flush socket
  }[;`.u.upd,MSG] each subscribers;
  };

sub:{[]
  subscribers,::.z.pw;                 // add subcriber
  };

.z.pc:{[H]
  subscribers::subscribers except H;   // remove subscriber
  };

\d .