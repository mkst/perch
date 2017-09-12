.util.Load `:lib/cfg/cfg.q;            / for .cfg
.util.Load `:lib/ipc/kdb.q;            / for pub/sub

MAXROWS:1000;                          / write to disk once MAXROWS exceeded

.u.upd:{[TABLE;DATA]
  $[TABLE in tables[];
    [
    TABLE upsert DATA;                 / existing table
    if[MAXROWS<count value TABLE;
      .[` sv LOGPATH,TABLE,`;();,;.Q.en[LOGPATH]`. TABLE]; / initialise and upsert to disk
      @[`.;TABLE;0#];                  / clear table
      ];
    ];
    TABLE set $[99h=type DATA;enlist DATA;DATA] / new table
    ];
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
  .ipc.subscribe each `$ "," vs .cfg.Config.Subscriptions;
  };

if[`rdbdisk_init.q=last `$"/" vs string .z.f;init[.z.x]];