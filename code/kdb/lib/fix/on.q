// On.XXX

On:(enlist `)!(enlist (::));

On.LOGON:{[MSG]
  .log.Inf "LOGON";
  if[.fix.IsLoggedOn;                  // already logged on
    .log.Wrn "Already logged on!";
    // TODO: handle this behaviour per FIX protocol
    :();
    ];
  .fix.IsLoggedOn:1b;                  //
  .fix.TestRequestPending:0b;          // reset pending test request flag

  .timer.Add[`.fix.HeartBeatCheckClient;0D00:00:01]; // add (outbound) heartbeat timer
  .timer.Add[`.fix.HeartBeatCheckServer;0D00:00:30]; // add (inbound) heartbeat timer
  };

On.LOGOUT:{[MSG]
  .log.Inf "LOGOUT";
  .fix.IsLoggedOn:0b;
  Send.LOGOUT map (58h;"Responding to logout request");
  .fix.Disconnect[];
  // clear out timers (FIXME: all?)
  delete from `timer.Timers
  };

On.HEARTBEAT:{[MSG]
  .log.Inf "HEARTBEAT";
  // reset test request
  .fix.TestRequestPending:0b
  };

On.TEST_REQUEST:{[MSG]
  .log.Inf "TEST_REQUEST";
  testReqId:MSG 112h;
  Send.HEARTBEAT map(112h;testReqId);
  };

On.REJECT:{[MSG]
  .log.Inf "REJECT"
  };

On.RESEND_REQUEST:{[MSG]
  .log.Inf "RESEND_REQUEST";
  from:"J"$MSG 7h;
  to:"J"$MSG 16h;
  // FIXME: does not support resending a range
  newSeqNum:1+.fix.SeqNumOut;
  // set current out sequence number (down) to requested 'from'
  .fix.SetSeqNumOut from;
  // gap-fill the requested range
  Send.SEQUENCE_RESET map(123h;"Y";       // GapFillFlag = True
                          36h;newSeqNum); // NewSeqNo
  // update outbound sequence number
  .fix.SetSeqNumOut newSeqNum;
  };

On.SEQUENCE_RESET:{[MSG]
  .log.Inf "SEQUENCE_RESET";
  .fix.SetSeqNumIn "J"$MSG 36h;
  };
