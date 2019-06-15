
.util.Load `:lib/ipc/kdb.q;
.util.Load `:lib/cfg/cfg.q;
.util.Load `:lib/timer/timer.q;

\d .ws

validate:{@[{(99h=type x;x:-9!x)};x;(0b;(::))] };

handle:{
  .log.Inf (".ws.handle!";x);
  msgType:`$x`msgType;
  if[not msgType in key `..On;
    .log.Wrn ("No handler for this msgType";msgType);
    :()
    ];
  `..On[msgType] . x[`reqId`payload]
  };

requests:([]h:`int$();id:`long$();req:());

subs:()!();

\d .

On:enlist[`]!enlist(::)

On.query:{[ID;PAYLOAD]
  .log.Inf `On.query;
  `requests upsert (.z.w;ID;PAYLOAD)
  };

On.sub:{
  .log.Inf `On.sub
  };
On.unsub:{
  .log.Inf `On.unsub
  };

h:hopen 5005

.z.ws:{
  if[first req:.ws.validate x;
    .ws.handle last req;
    neg[.z.w] -8!`msgType`reqId`payload!("response";last[req]`reqId;enlist[`dummy]!enlist[`dummy]);
    :()
    ];
  neg[.z.w] -8!enlist[`msgType]!enlist"error"
 };

\

on request: confirm valid, return ok/fail

msgType: connect, sub, query, unsub
reqId : id
payload: { variable_data ... }
