\d .socket

connect:.util.LoadLib[`socket;`k_connect;2];
send:.util.LoadLib[`socket;`k_send;1];

disconnect:{
  .z.sc x       // call .z.socketclose
  };

recv:{
  .z.ss raze x; // call .z.socketstream
  };

//-----------------
// public methods
//-----------------

Send:send;
Connect:{[IP;PORT]
  connect[IP;"i"$PORT]
  };

\d .
