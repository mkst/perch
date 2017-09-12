.util.LoadDir `:lib/schema;
/--------------------------------------
MAXROWS:100000; / GLOBAL maximum rows to hold in memory before writing to disk
/--------------------------------------
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
writeCoverageToDisk:{[PATH;DATE]
  path:(` sv PATH,DATE,`Coverage,`);
  .log.Inf ("Writing Coverage to";path);
  path upsert .Q.en[PATH] () xkey Coverage; / enumerate and write-down
  };
/--------------------------------------
writeToDiskMultiParted:{[PATH;DATE;TABLE]
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
/--------------------------------------
writeToDiskParted:{[PATH;DATE;TABLE]
  if[c:count get TABLE;
    .log.Inf ("Writing";c;"rows to";` sv PATH,DATE,TABLE,`);
    .Q.dpft[PATH;DATE;`sym;TABLE]      /dpft[directory;partition;`p#field;tablename]
    ];
  };
/--------------------------------------
if[not all `log`hdb in key opts:.Q.opt .z.x;
  .log.Err ("Usage: roll.q -log </path/to/log> -hdb </path/to/hdb [-multiparted -cov </path/to/coverage>]");
  exit 1
  ];
if[(not `cov in key opts) and isMultiParted:`multiparted in key opts;
  .log.Err ("Error: -cov is required if -multiparted is specified");
  exit 1
  ];
/--------------------------------------
LOGFILE:first opts[`log];              / logfile to be processed
DATE:`$string"D"$8#last"/"vs LOGFILE;  / date cast to symbol
PATH:`$":",first opts[`hdb];           / path for h(istorical)db
COVPATH:`$":",first opts[`cov];        / path for coverage table
/--------------------------------------
.u.upd:{[PATH;DATE;TABLE;DATA]
  TABLE upsert DATA;
  if[MAXROWS<count get TABLE;          / check whether 'cache' is full
    writeToDisk[PATH;DATE;TABLE];      / write TABLE to disk
    TABLE set 0#get TABLE              / empty TABLE
  ];
  }[PATH;DATE];                        / values from command arguments
/--------------------------------------
writeToDisk:$[isMultiParted;
  writeToDiskMultiParted;              / write to ./DATE/EXCH/SYM/TABLE
  writeToDiskParted];                  / write to ./DATE/TABLE/
/--------------------------------------
.log.Hlt ("Loading logfile";LOGFILE;"for date";DATE);
if[1=count res:-11!(-2;`$":",LOGFILE);
  .log.Wrn "Corrupt file detected, performing partial roll...";
  ];
/--------------------------------------
-11!(first res;`$":",LOGFILE);         / chunk through the LOGFILE
/--------------------------------------
writeToDisk[PATH;DATE;] each (tables[] except `Coverage); / write residual data
/--------------------------------------
if[isMultiParted;                      / if multi-parted we need to write the Coverage
  update path:PATH from `Coverage;     / update path
  writeCoverageToDisk[COVPATH;DATE];   / write down Coverage table
  if[not `extract.q in key COVPATH;    / copy extract.q to Coverage directory
    @[system;"cp ",(1_string .util.makepath `:scripts/extract.q)," ",1_string COVPATH;{.log.Err ("Failed to copy extract.q";x)}]
   ];
  ];
/--------------------------------------
.log.Hlt "Roll complete!";
/--------------------------------------
if[not `noexit in key opts;exit 0];    / exit on complete

