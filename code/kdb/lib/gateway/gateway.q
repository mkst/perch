.gw.init:.util.LoadLib[`gateway;`k_start;1];      // []
.gw.send:.util.LoadLib[`gateway;`k_send;2];       // [HANDLE;BYTES]
.gw.setport:.util.LoadLib[`gateway;`k_setport;1]; // PORT

\d .gw

requests:`id xkey flip `id`time`handle`processed`request!"jpib*"$\:();
ID:1;

`requests insert (0;.z.p;0i;1b;0xdeadbeef);

receive:{[HANDLE;REQUEST]
  .last.HANDLE:HANDLE;
  .last.REQUEST:REQUEST;
  `.gw.requests insert (ID;.z.p;HANDLE;0b;REQUEST);
  .gw.ID+:1;
  processQueue[]
  };

kResponse:{[RES]
  @[RES;1;:;0x02]                              // kdb response has 2nd byte set to 0x02
  };

process:{[REQ]
  header:4#REQ[`request];
  known:0b;
  //processed:0b;
  if[(header~0x01010000) or header~0x01010100; // uncompressed or compressed sync
    .log.Inf "SYNC request";
    .gw.send[REQ[`handle];kResponse -8! value -9!REQ[`request];
    known:1b
    ];
  if[header~0x01000000;
    .log.Inf "ASYNC request";
    value -9!REQ[`request];
    known:1b
    ];
  if[(not known) and (-2#REQ[`request])~0x0300; // likely a LOGON request
    .log.Inf "LOGON request";
    send[REQ[`handle];0x03];
    known:1b
    ];
  if[not known;
    .log.Inf "UNKNOWN request"
    ];

  update processed:1b from `.gw.requests where id=REQ[`id]
  };

processQueue:{[]
  process each 0!select from requests where not processed, id > 0; // select raze request by handle?
  };

\d .