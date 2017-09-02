//--------------------------------------
.cfg.:(::);                            / initialise .cfg namespace
.cfg.Config:()!();                     / initialise as empty dictionary
//--------------------------------------
\d .cfg

parseConfig:{[CFG]
  (`$first c)!last c:flip{cut[0,f;x _f:first where x="="]} each read0 CFG
  };

LoadConfig:{[CFG]
  .log.Inf ("Reading Configuration from";CFG);
  .cfg.Config:parseConfig CFG;
  };

\d .