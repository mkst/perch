/ pull data from hdb given row of coverage
extract:{[ROW]
  row:$[98h=type ROW;first ROW;ROW]; / take first row if multiple given
  exch:row[`exch];
  sym:row[`sym];
  table:row[`table];
  date:row[`date];
  path:row[`path];
  res:get .Q.dd[path;(exch;date;table;sym)];
  `date`time`timeExch`sym`exch xcols update date:date,sym:sym,exch:exch from res
  };