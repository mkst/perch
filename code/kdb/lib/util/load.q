
\d .util

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

LoadDir:{[PATH]
  Load each .Q.dd[PATH] each asc { x where any like[x;] each ("*.k";"*.q") } key makepath PATH
  };

Load:{[PATH]
  .util.lastLoadedPath:PATH;
  path:$["/"~string[PATH] 1;PATH;makepath PATH];
  system "l ",1_string path;           // use system l to load path
  :.log.Ldn path;                      // return loaded path
  };
\d .

Reload:{[]
  .util.Load .util.lastLoadedPath
  };
