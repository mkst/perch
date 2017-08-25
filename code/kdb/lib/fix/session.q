\d .fix

//--------------------------------------
PROTOCOL:"8=FIX.4.4\001";
HEARTBEAT_INTERVAL:0D00:00:30; // default to 30 seconds
SenderCompID:"CLIENT";
TargetCompID:"SERVER";

//--------------------------------------
SeqNumIn:SeqNumOut:1;
IsConnected:IsLoggedOn:0b;

//--------------------------------------
// Sequence number handling
//--------------------------------------
SetSeqNumIn:{
  .log.Inf ("Setting SeqNumIn as ",string x);
  .fix.SeqNumIn:x
  }
SetSeqNumOut:{
  .log.Inf ("Setting SeqNumOut as ",string x);
  .fix.SeqNumOut:x
  }

//--------------------------------------
// Heatbeat/TestRequest handling
//--------------------------------------
HeartBeatCheckClient:{[]
  now:.z.p;
  if[IsLoggedOn and now>lastSentTime+HEARTBEAT_INTERVAL;
    `..Send.HEARTBEAT map ()
    ];
  };

// Note: disconnect if no messages received for 60 seconds
TestRequestPending:0b;
HeartBeatCheckServer:{[]
  now:.z.p;
  if[IsLoggedOn and now>lastReceivedTime+HEARTBEAT_INTERVAL;
    // if they have not send anything for 2*heartbeat interval then disconnect
    if[.z.p>lastReceivedTime+2*HEARTBEAT_INTERVAL;
      `..Send.LOGOUT map (58h;"No response to test request(s)");
      Disconnect[]
      ];
    if[not TestRequestPending;
      `..Send.TEST_REQUEST map(112h;fixTs now);
      TestRequestPending::1b
      ]
    ];
  };

\d .
