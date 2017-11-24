// TODO, add some useful stuff here

system "l ",getenv[`KDB_HOME],"/lib/log/log.q";   // adds .log.*
system "l ",getenv[`KDB_HOME],"/lib/util/load.q"; // adds .util.Load
.util.Load `:lib/q/q.q;                           // adds map + more
.h.HOME:getenv[`WEB_HOME];                        // set html home
