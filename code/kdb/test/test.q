.util.LoadDir `:lib/socket;
.util.Load `:lib/cfg/cfg.q;
.util.Load `:lib/fix/socket.q;
.util.Load `:lib/timer/timer.q;
.util.Load `:lib/stp/bitstamp/trading.q;
.util.Load `:lib/stp/bitstamp/md.q;


.cfg.LoadConfig .util.CfgPath `:bitstamp_test.cfg;

.fix.SenderCompID:.cfg.Config.SenderCompID;
.fix.TargetCompID:.cfg.Config.TargetCompID;

Start:{[]
  $[.socket.Connect[.cfg.Config.Host;"I"$.cfg.Config.Port];
    [
    .log.Inf "Connect succeeded";
    .fix.IsConnected:1b;
    // send logon
    Send.LOGON[map (553h;.cfg.Config.Username;
                    554h;.cfg.Config.Password;
                    108h;.cfg.Config.HeartBeatInterval;
                    141h;"Y")]
    ];
    .log.Inf "Connection failed"
    ];
  };

order:map(`Symbol;`XRPEUR;
          `Quantity;1000f;
          `Price;123.45;
          `Side;`Buy;
          `ClientOrderID;1234;
          `OrderType;`Market);
