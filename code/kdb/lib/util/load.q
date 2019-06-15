
\d .util

loaded:()!();

makepath:{[PATH]
  `$":",getenv[`KDB_HOME],"/",$[":"~(s:string[PATH]) 0;1_s;s]
  };

CfgPath:{[PATH]
  `$":",getenv[`CFG_HOME],"/",$[":"~(s:$[10h=type PATH;PATH;string[PATH]]) 0;1_s;s]
  };

LoadLib:{[LIB;FUNC;PARAMETERS]
  path:.Q.dd[`$":",getenv[`C_HOME];(`lib;LIB;.z.o;LIB)];
  .log.Ldn ("Lib:";(last "/" vs string path);"::";FUNC;"(";PARAMETERS;")");
  path 2:(FUNC;PARAMETERS)
  };

/if order.txt is present, files will be loaded in that order
LoadDir:{[PATH]
  lf:$[`order.txt in k:key makepath PATH;
    `$ { x where not x like "#*" } read0 makepath .Q.dd[PATH;`order.txt];
    ()];
  Load each .Q.dd[PATH] each distinct (lf inter k),asc { x where any x like\:/:("*.q";"*.k") } key makepath PATH
  };

Load:{[PATH]
  .util.lastLoadedPath:PATH;
  path:$["/"~string[PATH] 1;PATH;makepath PATH];
  if[()~key path;
    '"file_not_found"];                / sanity check
  fileMD5:md5 raze read0 path;         / get md5 sum of file
  if[path in key loaded;               / file is already known
    if[loaded[path]~fileMD5;           / md5 matches loaded file
      .log.Ldn (path;"already loaded...");
      :()                              / early return
      ];
    ];
  system "l ",1_string path;           / use system l to load path
  loaded[path]:fileMD5;                / add file to list of loaded files
  :.log.Ldn path;                      / return loaded path
  };
\d .

Reload:{[]
  .util.Load .util.lastLoadedPath
  };
