.util.Load `:lib/analytics/analytics.q;

\p 5005

system"sleep 3"

\l /tmp/perch/rdb

.h.HOME:"/home/mark/github/perch/code/web";

query:{
  value .log.Inf x
  };
