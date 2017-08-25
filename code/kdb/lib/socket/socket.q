\d .socket

connect:.util.LoadLib[`socket;`k_connect;2];
send:.util.LoadLib[`socket;`k_send;1];
mult:.util.LoadLib[`socket;`multiply;2];

disconnect:{
  // call .z.socketclose
  .z.sc x
  };

recv:{
  // call .z.socketstream
  .z.ss raze x;
  };

//-----------------
// public methods
//-----------------

Send:send;
Connect:{[IP;PORT]
  connect[IP;"i"$PORT]
  };

\d .
