\d .log

colours:()!();
colours[`black]:"0;30m";
colours[`red]:"0;31m";
colours[`green]:"0;32m";
colours[`yellow]:"0;33m";
colours[`blue]:"0;34m";
colours[`purple]:"0;35m";
colours[`cuyan]:"0;36m";
colours[`white]:"0;37m";

Log:{[LEVEL;COLOUR;x]
  now:string .z.p;
  {[C;T;L;x] -1 "\033[",C,T,"\t",L,"\t",x,"\n\033[0m"}[COLOUR;string .z.p;LEVEL;] each "\n" vs split x;
  x
  };

split:{
  $[0h=t:type x;           // mixed list?
    " " sv .z.s each x;
    t in 98 99h;         // table or dictionary?
      -1 rotate .Q.s x;
      10h=t;             // string?
        x;
        t<0;             // atom?
          string x;
          " " sv string x
    ]
  };

Inf:.log.Log["INF";colours.black];     / information
Wrn:.log.Log["WRN";colours.yellow];    / warning
Err:.log.Log["ERR";colours.red];       / error
Ldn:.log.Log["LDN";colours.blue];      / loading
Hlt:.log.Log["INF";colours.white];     / highlight (e.g. important)
\d .
