.util.Load `:lib/cfg/cfg.q;            / for .cfg
.util.Load `:lib/ipc/kdb.q;            / for pub/sub

TODAY:0Nd;                             / initialise as null date
HANDLE:0Ni;                            / initialise as null integer

.u.upd:{[TABLE;DATA]
  if[TODAY<>.z.d;
    .log.Inf "New day detected...";
    if[not null HANDLE;hclose HANDLE];
    LOGFILE::` sv LOGPATH,`$except[string today:.z.d;"."];
    LOGFILE set ();                    / initialise logfile to null
    HANDLE::hopen LOGFILE;
    TODAY::today;
  ];
  HANDLE enlist (`.u.upd;TABLE;DATA);  / write to logfile
  .ipc.pub (TABLE;DATA)                / publish update
  };

.z.exit:{[]
  if[not null HANDLE;hclose HANDLE];
  };

init:{[ARGS]
  opts::.Q.opt ARGS;
  if[not `config in key opts;
    .log.Err "logger_init.q -config <path/to/config.cfg>";
    exit 1
  ];
  .cfg.LoadConfig `$":",first opts`config;
  system "p ",.cfg.Config.ListenPort;  / start listening
  LOGPATH::`$":",.cfg.Config.LogPath;  / set LOGPATH
  .ipc.subscribe each `$ "," vs .cfg.Config.Subscriptions;
  };

if[`logger_init.q=last `$"/" vs string .z.f;init[.z.x]];