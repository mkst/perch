\d .log

Inf:{[x]
  .log.Log["INF";x]
  }

Wrn:{[x]
  .log.Log["WRN";x]
  }

Err:{[x]
  .log.Log["ERR";x]
  }

Ldn:{[x]
  .log.Log["LDN";x]
  }

Log:{[x;y]
  now:string .z.p;
  /{-1 x,"\t",y,"\t",z,"\n"}[now;x;] each -1_"\n" vs .Q.s[y];
  { -1 x,"\t",y,"\t",z,"\n" }[string .z.p;x;] each "\n" vs split y;
  y
  };

split:{
  $[0h=t:type x;
    " " sv .z.s each x;
    $[98h=t;
      -1 rotate .Q.s x;
      $[10h=t;
        x;
        $[t<0;
          string x;
          " " sv string x
          ]
        ]
      ]
    ]
  };
\d .
