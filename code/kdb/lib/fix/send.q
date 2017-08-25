
\d .fix

send:{[MSG]
  .fix.lastSentMsg: `..s2p MSG;
  .fix.lastSentTime:.z.p;
  // send down socket
  .socket.Send MSG;
  // increment outbound sequence number
  .fix.SeqNumOut+:1;
  };

\d .

Send:(enlist `)!(enlist (::));

// session level
Send.LOGON:{[MSG]
  .fix.send[.fix.buildMessage[MSG;.fix.fdr `LOGON]]
  };

Send.LOGOUT:{[MSG]
  .fix.send[.fix.buildMessage[MSG;.fix.fdr `LOGOUT]];
  .fix.Disconnect[]
  };

Send.HEARTBEAT:{[MSG]
  .fix.send[.fix.buildMessage[MSG;.fix.fdr `HEARTBEAT]]
  };

Send.TEST_REQUEST:{[MSG]
  .fix.send[.fix.buildMessage[MSG;.fix.fdr `TEST_REQUEST]]
  };

Send.RESEND_REQUEST:{[MSG]
  //TODO: add pending RESEND_REQUEST check
  .fix.send[.fix.buildMessage[MSG;.fix.fdr `RESEND_REQUEST]]
  };
//--------------------------------------

// application level
Send.NEW_ORDER_SINGLE:{[MSG]
  .fix.send[.fix.buildMessage[MSG;.fix.fdr `NEW_ORDER_SINGLE]]
  };
