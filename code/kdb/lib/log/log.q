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
  {-1 x,"\t",y,"\t",z,"\n"}[now;x;] each -1_"\n" vs .Q.s[y];
  y
  };

\d .
