\d .fix

inbound:outbound:0Ni;

Log:{[HANDLE;DIR;MSG]
  if[not null HANDLE;
    neg[HANDLE] string[.z.p]," ",DIR," ",MSG
  ];
  MSG
  };

LogOutbound:{[MSG]
  Log[outbound;"OUT";MSG]
  };

LogInbound:{[MSG]
  Log[inbound;"IN ";MSG]
  };

\d .

