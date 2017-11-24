# perch
Not quite a trading _platform_, written in q/kdb+. Very unfinished.

_"...Look on my works, ye mighty, and despair!"_

## TODO

 - [x] book builder (convert quotes into books)
 - [x] subscribers reconnect on disconnect (basic)
 - [ ] pool builder (aggregate books into pools)
 - [ ] order manager
 - [ ] HTML5 front-end for order manager
 - [ ] investigate alternative messaging protocol (e.g. zeromq)

## Tutorial

**Compile shared objects**

    $ cd ./code/c/lib/socket/ && make

**Start up logger, rdb, bookbuilder, bitstamp gateway & analytics**

    $ ./scripts/bitstamp.sh

**Roll log to HDB (multi-parted)**

    $ q32 code/kdb/scripts/roll.q -log /tmp/perch/log/20171124 -hdb /tmp/perch/hdb -cov /tmp/perch/cover -multiparted

**Read data from HDB (multi-parted)**

```
q)\l /tmp/perch/cover
q)select from Coverage
date       table sym    exch start                         end                           num   path           
--------------------------------------------------------------------------------------------------------------
2017.11.24 BBO   BTCUSD BITS 2017.11.24D18:48:56.482520000 2017.11.24D18:50:58.897789000 64    :/tmp/perch/hdb
2017.11.24 BBO   BTCEUR BITS 2017.11.24D18:48:56.487848000 2017.11.24D18:50:47.955632000 15    :/tmp/perch/hdb
2017.11.24 BBO   EURUSD BITS 2017.11.24D18:48:56.488533000 2017.11.24D18:50:59.809528000 74    :/tmp/perch/hdb
2017.11.24 Book  BTCUSD BITS 2017.11.24D18:48:56.482520000 2017.11.24D18:50:58.897789000 106   :/tmp/perch/hdb
2017.11.24 Book  BTCEUR BITS 2017.11.24D18:48:56.487848000 2017.11.24D18:50:59.725295000 105   :/tmp/perch/hdb
2017.11.24 Book  EURUSD BITS 2017.11.24D18:48:56.488533000 2017.11.24D18:50:59.809528000 110   :/tmp/perch/hdb
2017.11.24 Quote BTCUSD BITS 2017.11.24D18:48:56.481505000 2017.11.24D18:50:58.891458000 21040 :/tmp/perch/hdb
2017.11.24 Quote BTCEUR BITS 2017.11.24D18:48:56.486751000 2017.11.24D18:50:59.717426000 20840 :/tmp/perch/hdb
2017.11.24 Quote EURUSD BITS 2017.11.24D18:48:56.487226000 2017.11.24D18:50:59.805242000 21840 :/tmp/perch/hdb
2017.11.24 Trade BTCUSD BITS 2017.11.24D18:48:56.481811000 2017.11.24D18:50:54.522541000 60    :/tmp/perch/hdb
2017.11.24 Trade BTCEUR BITS 2017.11.24D18:48:56.487072000 2017.11.24D18:50:47.619267000 18    :/tmp/perch/hdb
2017.11.24 Trade EURUSD BITS 2017.11.24D18:48:56.487448000 2017.11.24D18:50:32.060525000 6     :/tmp/perch/hdb

q)extract select from Coverage where date=2017.11.24, table=`Quote, sym=`BTCUSD
date       time                          timeExch                      sym    exch side price   qty        action snapshot
--------------------------------------------------------------------------------------------------------------------------
2017.11.24 2017.11.24D18:48:56.481505000 2017.11.24D18:48:56.425000000 BTCUSD BITS B    8265    0.2251282  N      1       
2017.11.24 2017.11.24D18:48:56.481505000 2017.11.24D18:48:56.425000000 BTCUSD BITS B    8254.59 1.4952     N      1       
2017.11.24 2017.11.24D18:48:56.481505000 2017.11.24D18:48:56.425000000 BTCUSD BITS B    8254.57 1.2062     N      1       
2017.11.24 2017.11.24D18:48:56.481505000 2017.11.24D18:48:56.425000000 BTCUSD BITS B    8253.74 19.67719   N      1       
2017.11.24 2017.11.24D18:48:56.481505000 2017.11.24D18:48:56.425000000 BTCUSD BITS B    8250    1.131913   N      1       
2017.11.24 2017.11.24D18:48:56.481505000 2017.11.24D18:48:56.425000000 BTCUSD BITS B    8248    0.1196997  N      1       
2017.11.24 2017.11.24D18:48:56.481505000 2017.11.24D18:48:56.425000000 BTCUSD BITS B    8241.11 2.9988     N      1       
2017.11.24 2017.11.24D18:48:56.481505000 2017.11.24D18:48:56.425000000 BTCUSD BITS B    8241.09 0.2284482  N      1       
2017.11.24 2017.11.24D18:48:56.481505000 2017.11.24D18:48:56.425000000 BTCUSD BITS B    8241.06 13.23785   N      1    
..
```

**Roll log to HDB (parted)**

    q32 code/kdb/scripts/roll.q -log /tmp/perch/log/20171124 -hdb /tmp/perch/hdb2

**Read data from HDB (parted)**
```
q)\l /tmp/perch/hdb2
q)tables[]
`s#`BBO`Book`Quote`Trade
q)select from Trade where date=last date, sym=`BTCUSD
date       sym    time                          timeExch                      exch side price   qty        id      
-------------------------------------------------------------------------------------------------------------------
2017.11.24 BTCUSD 2017.11.24D18:48:56.481811000 2017.11.24D18:48:30.000000000 BITS X    8270.06 0.1718778  27446276
2017.11.24 BTCUSD 2017.11.24D18:49:10.866386000 2017.11.24D18:49:10.000000000 BITS X    8265    0.1691656  27446306
2017.11.24 BTCUSD 2017.11.24D18:49:23.661188000 2017.11.24D18:49:23.000000000 BITS X    8269.59 0.00090683 27446324
2017.11.24 BTCUSD 2017.11.24D18:49:23.779136000 2017.11.24D18:49:23.000000000 BITS X    8269.6  0.00090692 27446326
2017.11.24 BTCUSD 2017.11.24D18:49:23.846100000 2017.11.24D18:49:23.000000000 BITS X    8269.6  0.00090691 27446328
2017.11.24 BTCUSD 2017.11.24D18:49:23.941200000 2017.11.24D18:49:23.000000000 BITS X    8269.61 0.00078591 27446329
2017.11.24 BTCUSD 2017.11.24D18:49:24.025934000 2017.11.24D18:49:23.000000000 BITS X    8269.62 0.02887223 27446330
..
q)meta Trade
c       | t f a
--------| -----
date    | d    
sym     | s   p
time    | p    
timeExch| p    
exch    | s    
side    | c    
price   | f    
qty     | f    
id      | j
```
**Example query against HDB**
```
q)vwap:{$[z>last s:sums x;0n;wavg[deltas z&s;y]]}
q)/aj all and pick 10 random trades, calculate vwap mid price
q)10?select date, time, sym, exch, price, qty, mid:vmid, diff:abs(vmid-price) from update vmid:.5*vbid+vask from update vbid:vwap'[bidqty;bidpx;qty], vask:vwap'[askqty;askpx;qty] from aj[`sym`time;select from Trade where date=last date;select from Book where date=last date]
date       time                          sym    exch price   qty        mid      diff      
-------------------------------------------------------------------------------------------
2017.11.24 2017.11.24D18:50:19.994639000 BTCUSD BITS 8269.41 0.00078594 8262.11  7.299998  
2017.11.24 2017.11.24D18:49:54.189139000 BTCUSD BITS 8269.59 0.00066486 8262.205 7.385     
2017.11.24 2017.11.24D18:51:24.348548000 BTCUSD BITS 8254.4  0.0164427  8261.945 7.545     
2017.11.24 2017.11.24D18:53:39.136744000 BTCEUR BITS 6940.02 0.0021     6943.49  3.47      
2017.11.24 2017.11.24D18:50:10.856727000 BTCEUR BITS 6949.98 0.114      6944.998 4.98207   
2017.11.24 2017.11.24D18:49:24.025934000 BTCUSD BITS 8269.62 0.02887223 8267.309 2.311235  
2017.11.24 2017.11.24D18:50:24.318900000 BTCUSD BITS 8270.04 0.00066528 8270.045 0.005     
2017.11.24 2017.11.24D18:50:39.365629000 BTCUSD BITS 8270.01 0.05379207 8270.035 0.02462925
2017.11.24 2017.11.24D18:51:59.204386000 BTCUSD BITS 8253.74 1.687082   8255.707 1.967346  
2017.11.24 2017.11.24D18:51:19.464555000 BTCUSD BITS 8255.19 0.4278546  8262.4   7.209989  
```