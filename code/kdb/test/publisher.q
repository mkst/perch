.util.Load `:lib/ipc/kdb.q;
.util.Load `:lib/timer/timer.q;

.util.LoadDir `:lib/schema;

syms:`BTCEUR`BTCUSD`EURUSD;
exchs:`BITS`KRKN`MTGX;

publish:{[]
  n:100;
  `Quote upsert flip (n#.z.p;n#.z.p+1000;n?syms;n#1?exchs;n?"BS";n?1f;n?1000f;n?"NDU";n?01b);
  .log.Inf ("Publishing";count Quote;"records");
  {.ipc.pub (`Quote;Quote where Quote[`sym] = x) } each exec distinct sym from Quote;
  Quote::0#Quote;
  };

PORT:12345;
.log.Inf ("Listening on port";PORT);
system "p ",string PORT;
.timer.Add[`publish;0D00:00:01];       / publish every second
