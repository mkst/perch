.util.Load `:lib/fix/fix.q;
.util.Load `:lib/fix/protocol.q;
.util.Load `:lib/fix/session.q;
.util.Load `:lib/fix/on.q;
.util.Load `:lib/fix/send.q;

chunk:"";
delimiter:"\00110=???\001";

.z.ss:{[MSG]                           // .z.s(ocket)s(tream)
  msg:chunk,MSG;                       // prepend chunk to incoming message;
  if[null first d:ss[MSG;delimiter];   // search for '|10=???|', (end of the message)
    chunk::msg;
    :()                                // return if we havent found the end of the message
    ];
  chunk::"";                           // reset chunk
  .fix.onMessage each -1 _ (0,8 + d) cut msg; // call onMessage with each message
  };

.z.sc:{[]                              // .z.s(ocket)c(lose)
  .log.Wrn "Socket has been closed";   // TODO: any cleanup?
  .fix.IsLoggedOn:0b;
  .fix.IsConnected:0b;
  };

\d .fix

Disconnect:{[]
  .log.Inf "Disconnection request";
  // TODO: implement .socket.force_disconect[]
  .fix.IsConnected:0b;
  };

onMessage:{[MSG]
  .log.Inf ("In";decode MSG);
  .fix.lastReceivedTime:.z.p;
  .fix.lastRawMsg:MSG;
  // TODO: log message to disk
  msg:decode MSG;                      // decode message, FIX -> dictionary
  if[not validate msg;                 // quick sanity
    .log.Wrn "Invalid message received"; // ignore invalid messages
    :()                                // NOTE: do not increment sequence number
    ];

  msgType:msg 35h;                     // MsgType, tag 35
  if[not msgType in fdr;
    .log.Err ("Unsupported MsgType ",msgType," ignoring...");
    SeqNumIn+::1;                      // increment sequence number
    :()
    ];

  mt:fd `$msgType;                     // map to friendly name
  .fix.lastmt:mt;                      // DEBUG

  // Happy path
  if[IsLoggedOn and (SeqNumIn=msgSeqNum:first "J"$msg 34h) and mt in key `..On;
    SeqNumIn+::1;                      // increment sequence number
    `..On[mt] msg;                     // trigger "On" message handler
    :()
    ];

  .log.Wrn ("Off the happy path...";msgSeqNum);    // DEBUG

  if[not IsLoggedOn;                   // not currently logged on
    if[not `LOGON=mt;                  // first message must be a LOGON
       `..Send.LOGOUT map(58h;"ERROR: First message must be LOGON");
       :()
    ];
    // TODO: move logic into On.LOGON?
    if["Y"~first msg 141h;             // ResetSeqNum=Y
      SeqNumIn::SeqNumOut::1;          // reset both in and out sequence numbers
      `..On.LOGON msg;                 // process logon
      :()
      ];
    if[SeqNumIn=msgSeqNum;             // sequence number is as expected
      SeqNumIn+::1;
      `..On.LOGON msg;                 // process logon
      :()
      ];
    if[SeqNumIn<msgSeqNum;             // sequence number is higher than expected
      `..On.LOGON msg;                 // process logon
      `..Send.RESEND_REQUEST map (8h;SeqNumIn;16h;0); // request replay
      :()
      ];
    // otherwise seq num is too low
    `..Send.LOGOUT map(58h;"ERROR: MsgSeqNum ",string[msgSeqNum]," lower than expected: ",string SeqNumIn)
    ];

  // session is logged on but still not happy path

  if[SeqNumIn>msgSeqNum; // check for sequence number too low
      `..Send.LOGOUT map(58h;"ERROR: MsgSeqNum ",string[msgSeqNum]," lower than expected: ",string SeqNumIn)
    ];

  // check for sequence number too high
  if[SeqNumIn<msgSeqNum;
    .log.Inf ("Sequence number higher than expected, sending RESEND_REQUEST");
    // NOTE: do not increment sequence number
    `..Send.RESEND_REQUEST map(8h;SeqNumIn;16h;0); // Request replay
    :()
    ];

  if[not mt in key `..On;
    // TODO
    .log.Wrn ("No On handler for ";mt); // DEBUG
    '"UNHANDLED_MESSAGE"
    ];

  };

\d .
