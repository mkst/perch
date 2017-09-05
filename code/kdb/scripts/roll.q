.util.LoadDir `:lib/schema;

MAXROWS:100000; / maximum rows to hold in memory before writing to disk

writeToDisk:{[PATH;DATE;TABLE]
  if[c:count get TABLE;
    {[TABLE;PATH;DATE;EXCH]
      {[TABLE;PATH;DATE;EXCH;SYM]
        tab:delete sym,exch from select from TABLE where exch=EXCH,sym=SYM; / remove sym and exch columns
        path:(` sv PATH,EXCH,DATE,TABLE,SYM);                               / build path
        .log.Inf ("Writing";count tab;"rows to";path);
        (` sv path,`) upsert .Q.en[PATH] tab                                / save splayed
      }[TABLE;PATH;DATE;EXCH] each exec distinct sym from select from TABLE where exch=EXCH;
    }[TABLE;PATH;DATE;] each exec distinct exch from TABLE;
    ];
  };

if[not all `log`hdb in key opts:.Q.opt .z.x;
  .log.Err ("Usage: roll.q -log </path/to/log> -hdb </path/to/hdb");
  exit 1
  ];

LOGFILE:first opts[`log];              / logfile to be processed
DATE:`$8#last"/"vs LOGFILE;            / date cast to symbol
PATH:`$":",first opts[`hdb];           / path for h(istorical)db

.u.upd:{[PATH;DATE;TABLE;DATA]
  TABLE upsert DATA;
  if[MAXROWS<count get TABLE;
    writeToDisk[PATH;DATE;TABLE];      / write TABLE to disk
    TABLE set 0#get TABLE              / empty TABLE
  ];
  }[PATH;DATE];

.log.Inf ("Loading logfile";LOGFILE;"for date";DATE);
-11!`$":",LOGFILE;
writeToDisk[PATH;DATE;] each tables[]; / write residual data