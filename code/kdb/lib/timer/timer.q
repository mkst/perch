\d .timer

id:0;

Timers:`id xkey flip `id`interval`nextRun`function!"jpn*"$\:();

//triggers immediately
Add:{[FUNC;INTERVAL]
  Timers[id]:(INTERVAL;.z.p;FUNC);
  oid:id;
  id+::1;
  oid                                  // return id of added job
  };

execJob:{[FUNC]
  (value FUNC) `                       // execute function with no args
  };

GetTimestamp:{[]
  .z.p                                 // return now, allows mocking
  };

\d .

system "t 100" // 100ms precision
.z.ts:{
  jobs:select from .timer.Timers where nextRun <= .z.p;
  if[count jobs;
    .timer.execJob each exec function from jobs;
    update nextRun:.z.p+interval from `.timer.Timers where id in exec id from jobs
    ];
  };
