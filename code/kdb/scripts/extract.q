/ pull data from hdb given row of coverage
extract:{[ROW]
  row:$[98h=type ROW;first ROW;ROW];   / take first row if multiple given
  exch:row[`exch];
  sym:row[`sym];
  table:row[`table];
  date:row[`date];
  path:row[`path];
  if[()~key fullPath:.Q.dd[path;(exch;date;table;sym)];
    '"not_found"];                     / throw error if folder doesnt exist
  res:get fullPath;                    / otherwise get folder
  `date`time`timeExch`sym`exch xcols update date:date,sym:sym,exch:exch from res
  };