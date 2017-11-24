.util.Load `:lib/cfg/cfg.q;            / for .cfg
.util.Load `:lib/ipc/kdb.q;            / for pub/sub
.util.Load `:lib/timer/timer.q;        / for timers

MAXROWS:1000;                          / write to disk once MAXROWS exceeded

.u.upd:{[TABLE;DATA]
  $[TABLE in tables[];
    [
    TABLE upsert DATA;                 / existing table
    if[MAXROWS<count value TABLE;
      write TABLE
      ];
    ];
    TABLE set $[99h=type DATA;enlist DATA;DATA] / new table
    ];
  };

write:{[TABLE]
  if[count value TABLE;
    .[` sv LOGPATH,TABLE,`;();,;.Q.en[LOGPATH]`. TABLE]; / initialise and upsert to disk
    @[`.;TABLE;0#];                  / clear table
    ];
  };

writeAll:{
  write each tables[]
  };

init:{[ARGS]
  opts::.Q.opt ARGS;
  if[not `config in key opts;
    .log.Err "rdbdisk_init.q -config <path/to/config.cfg>";
    exit 1
  ];
  .cfg.LoadConfig `$":",first opts`config;
  system "p ",.cfg.Config.ListenPort;  / start listening
  LOGPATH::`$":",.cfg.Config.LogPath;  / set LOGPATH
  system "rm -rf ",.cfg.Config.LogPath; / delete any previous RDB
  .ipc.subscribe each `$ "," vs .cfg.Config.Subscriptions;
  .timer.Add[`writeAll;0D00:05]       / write down every 5 minutes for low-update tables
  };

if[`rdbdisk_init.q=last `$"/" vs string .z.f;init[.z.x]];