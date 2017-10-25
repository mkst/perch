.util.LoadDir `:lib/socket;
.util.Load `:lib/ipc/kdb.q;
.util.Load `:lib/cfg/cfg.q;
.util.Load `:lib/fix/socket.q;
.util.Load `:lib/timer/timer.q;
.util.Load `:lib/stp/bitstamp/trading.q;
.util.Load `:lib/stp/bitstamp/md.q;

.cfg.LoadConfig .util.CfgPath `:prod/bitstamp_test.cfg;

.fix.SenderCompID:.cfg.Config.SenderCompID;
.fix.TargetCompID:.cfg.Config.TargetCompID;

SetupLogs:{[]
  prefix:":",.cfg.Config.LogPath,"/",string[.z.d],"_",.fix.SenderCompID,"-",.fix.TargetCompID;
  .fix.inboundLogFile: `$ prefix,"-IN.txt";
  .fix.outboundLogFile: `$ prefix,"-OUT.txt";
  .fix.inbound:hopen .fix.inboundLogFile;
  .fix.outbound:hopen .fix.outboundLogFile
  };

Start:{[]
  SetupLogs[]; / open logfiles

  $[.socket.Connect[.cfg.Config.Host;"I"$.cfg.Config.Port];
    [
    .log.Inf "Connect succeeded";
    .fix.IsConnected:1b;
    // send logon
    Send.LOGON[map (553h;.cfg.Config.Username;
                    554h;.cfg.Config.Password;
                    108h;.cfg.Config.HeartBeatInterval;
                    98h;"0";
                    141h;"Y")]
    ];
    [
    .log.Wrn "Connection failed";
    :()
    ]
    ];
  // subscribe to some crosses
  Subscribe `BTCUSD;
  Subscribe `BTCEUR;
  Subscribe `EURUSD
  };
