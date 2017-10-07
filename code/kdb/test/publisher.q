.util.Load `:lib/ipc/kdb.q;
.util.Load `:lib/timer/timer.q;

.util.LoadDir `:lib/schema;

syms:`BTCEUR`BTCUSD`EURUSD;
exchs:`BITS`KRKN`MTGX;

publish:{[]
  n:1+first 1?10;
  exch:1?exchs; / pick a single exchange per call
  `Quote upsert flip (n#.z.p;n#.z.p+1000;n?syms;n#exch;n?"BS";n?1f;n?1000f;n?"NDU";n?0000000001b);
  .log.Inf ("Publishing";count Quote;"records");
  {.ipc.pub (`Quote;Quote where Quote[`sym] = x) } each exec distinct sym from Quote;
  Quote::0#Quote;
  };

PORT:5001;
if[0=system "p";
  .log.Inf ("Listening on default port:";PORT);
  system "p ",string PORT;
  ];
.timer.Add[`publish;0D00:00:01];       / publish every second
