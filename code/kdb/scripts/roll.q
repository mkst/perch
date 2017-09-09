.util.LoadDir `:lib/schema;

MAXROWS:100000; / maximum rows to hold in memory before writing to disk

Coverage: `table`sym`exch xkey flip `table`sym`exch`start`end`num`path!"sssppjs"$\:();

updateCoverage:{[TABLE]
  .log.Inf (`updateCoverage;TABLE);
  {[TABLE;EXCH]
    {[TABLE;EXCH;SYM]
      cover:Coverage[(TABLE;SYM;EXCH)];
      table:select from TABLE where exch=EXCH, sym=SYM;
      tstart:exec first time from table;
      tend:exec last time from table;
      tnum:count table;
      $[all null cover;
        Coverage[(TABLE;SYM;EXCH)]:(tstart;tend;tnum;`); / initialise
        update start:min(start;tstart), end:max(end;tend), num:num+tnum from `Coverage where exch=EXCH,sym=SYM];
    }[TABLE;EXCH;] each exec distinct sym from TABLE where exch=EXCH;
  }[TABLE;] each exec distinct exch from TABLE;
  };

writeCoveragetoDisk:{[PATH;DATE]
  path:(` sv PATH,DATE,`Coverage,`);
  .log.Inf ("Writing coverage to";path);
  path upsert .Q.en[PATH] () xkey Coverage; / enumerate and write-down
  };

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
  updateCoverage TABLE;
  };

if[not all `log`hdb`cov in key opts:.Q.opt .z.x;
  .log.Err ("Usage: roll.q -log </path/to/log> -hdb </path/to/hdb -cov </path/to/coverage>");
  exit 1
  ];

LOGFILE:first opts[`log];              / logfile to be processed
DATE:`$string"D"$8#last"/"vs LOGFILE;  / date cast to symbol
PATH:`$":",first opts[`hdb];           / path for h(istorical)db
COVPATH:`$":",first opts[`cov];        / path for coverage table

.u.upd:{[PATH;DATE;TABLE;DATA]
  TABLE upsert DATA;
  if[MAXROWS<count get TABLE;
    writeToDisk[PATH;DATE;TABLE];      / write TABLE to disk
    TABLE set 0#get TABLE              / empty TABLE
  ];
  }[PATH;DATE];

.log.Inf ("Loading logfile";LOGFILE;"for date";DATE);
-11!`$":",LOGFILE;
writeToDisk[PATH;DATE;] each (tables[] except `Coverage); / write residual data
update path:PATH from `Coverage;       / update path
writeCoveragetoDisk[COVPATH;DATE];     / write down Coverage table
if[not `extract.q in key COVPATH;      / copy extract.q to Coverage directory
  @[system;"cp ",(1_string .util.makepath `:scripts/extract.q)," ",1_string COVPATH;{.log.Err ("Failed to copy extract.q";x)}]
 ];
