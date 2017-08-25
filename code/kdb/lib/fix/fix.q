\d .fix

decode:{(5h$first x)!last x:"I=\001"0:x};
encode:{raze(string key x){x,"=",$[10h=type y;y;string y],"\001"}'value x};

validate:{ all (8 9 34 35 10h) in key x };

checksum:{-3#"00",string (sum `int$x) mod 256};
addChecksum:{x,"10=",checksum[x],"\001"};

bodylength:{string count x};
addBodylength:{ "9=",bodylength[x],"\001",x };

// pull out chars we want, then replace the D for a -
fixTs:{@[string[x] 0 1 2 3 5 6 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22;8;:;"-"]};

// to allow for replaying
now:{.z.p};

buildHeader:{[MSGTYPE]
  (35 34 49 56 52h)!(MSGTYPE;SeqNumOut;SenderCompID;TargetCompID;fixTs now[]) };

buildMessage:{[MSG;MSGTYPE]
  addChecksum[PROTOCOL,addBodylength[encode[buildHeader[MSGTYPE],MSG]]] };

\d .

toFixSide:map(`Buy;"1";
              `Sell;"2");

fromFixSide:map("1";`Buy;
                "2";`Sell);

toFixOrderType:map(`Market;"1";
                   `Limit;"2");

p2s:{ssr[x;"|";"\001"]}; //
s2p:{ssr[x;"\001";"|"]}; //

// performance testing
// decodes @ ~510k/s
// encodes @ ~140k/s
// add checksum @ ~ 350k/s
