\d .fix

// message type -> friendly name
fd:map(`0;`HEARTBEAT;
       `1;`TEST_REQUEST;
       `2;`RESEND_REQUEST;
       `3;`REJECT;
       `4;`SEQUENCE_RESET;
       `5;`LOGOUT;
       `8;`EXECUTION_REPORT;
       `A;`LOGON;
       `D;`NEW_ORDER_SINGLE;
       `F;`ORDER_CANCEL_REQUEST;
       `V;`MARKET_DATA_REQUEST;
       `W;`MARKET_DATA_SNAPSHOT;
       `X;`MARKET_DATA_INCREMENT;
       `Y;`MARKET_DATA_REQUEST_REJECT;
       `j;`BUSINESS_MESSAGE_REJECT);

// friendly name -> message type
fdr: {(value x)!string key x} fd;

\d .
