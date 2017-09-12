# perch
Not quite a trading _platform_, written in q. Very unfinished.

_"...Look on my works, ye mighty, and despair!"_

## TODO

 - [x] book builder (convert quotes into books)
 - [x] subscribers reconnect on disconnect (basic)
 - [ ] pool builder (aggregate books into pools)
 - [ ] order manager
 - [ ] HTML5 front-end for order manager
 - [ ] investigate alternative messaging protocol (e.g. zeromq)

## Tutorial

**Setup environment/paths**

    source scripts/env.sh

**Start up dummy quote publisher (on port 5001)**

    q32 code/kdb/test/publisher.q -p 5001

**Start up bookbuilder**

    q32 code/kdb/procs/bookbuilder_init.q -config config/examples/bookbuilder.q

**Start up logger**

    q32 code/kdb/procs/logger/logger_init.q -config config/examples/logger.cfg

**Start up rdb (disk)**

    q32 code/kdb/procs/rdbdisk/rdbdisk_init.q -config config/examples/rdbdisk.cfg

**Roll log to HDB (multi-parted)**

    q32 code/kdb/scripts/roll.q -log /tmp/log/20170909 -hdb /data/hdb -cov /data/cover -multiparted

**Read data from HDB (multi-parted)**

```
q)\l /data/cover
q)select from Coverage
date       table sym    exch start                         end                           num   path            
---------------------------------------------------------------------------------------------------------------
2017.09.09 Quote BTCEUR KRKN 2017.09.09D10:25:35.628962000 2017.09.09D10:53:54.029092000 16674 :/data/hdb
2017.09.09 Quote BTCUSD KRKN 2017.09.09D10:25:35.628962000 2017.09.09D10:53:54.029092000 16528 :/data/hdb
2017.09.09 Quote EURUSD KRKN 2017.09.09D10:25:35.628962000 2017.09.09D10:53:54.029092000 16698 :/data/hdb
2017.09.09 Quote BTCUSD BITS 2017.09.09D10:25:36.729101000 2017.09.09D10:53:55.129028000 16516 :/data/hdb
2017.09.09 Quote BTCEUR BITS 2017.09.09D10:25:36.729101000 2017.09.09D10:53:55.129028000 16524 :/data/hdb
2017.09.09 Quote EURUSD BITS 2017.09.09D10:25:36.729101000 2017.09.09D10:53:55.129028000 16260 :/data/hdb
2017.09.09 Quote EURUSD MTGX 2017.09.09D10:25:38.929028000 2017.09.09D10:53:56.229095000 18548 :/data/hdb
2017.09.09 Quote BTCEUR MTGX 2017.09.09D10:25:38.929028000 2017.09.09D10:53:56.229095000 18556 :/data/hdb
2017.09.09 Quote BTCUSD MTGX 2017.09.09D10:25:38.929028000 2017.09.09D10:53:56.229095000 18396 :/data/hdb
q)extract select from Coverage where date=2017.09.09,table=`Quote,sym=`BTCUSD,exch=`MTGX
date       sym    exch time                          timeExch                      side price       qty      action snapshot
----------------------------------------------------------------------------------------------------------------------------
2017.09.09 BTCUSD MTGX 2017.09.09D10:25:38.929028000 2017.09.09D10:25:38.929024000 S    0.6676175   869.4906 U      1       
2017.09.09 BTCUSD MTGX 2017.09.09D10:25:38.929028000 2017.09.09D10:25:38.929024000 S    0.143963    51.0387  U      1       
2017.09.09 BTCUSD MTGX 2017.09.09D10:25:38.929028000 2017.09.09D10:25:38.929024000 S    0.2696229   420.2817 N      0       
2017.09.09 BTCUSD MTGX 2017.09.09D10:25:38.929028000 2017.09.09D10:25:38.929024000 B    0.1422971   275.2264 N      0       
2017.09.09 BTCUSD MTGX 2017.09.09D10:25:38.929028000 2017.09.09D10:25:38.929024000 S    0.08801059  202.7525 N      0      
..
```

**Roll log to HDB (parted)**

    q32 code/kdb/scripts/roll.q -log /tmp/log/20170912 -hdb /data/hdb

**Read data from HDB (parted)**

```
q)select from Quote where date=2017.09.12,sym=`BTCUSD,exch=`MTGX
date       sym    time                          timeExch                      exch side price     qty      action snapshot
--------------------------------------------------------------------------------------------------------------------------
2017.09.12 BTCUSD 2017.09.12D19:40:06.109804000 2017.09.12D19:40:06.109802000 MTGX B    0.2161185 668.5208 D      1       
2017.09.12 BTCUSD 2017.09.12D19:40:06.109804000 2017.09.12D19:40:06.109802000 MTGX B    0.7076901 972.4203 N      1       
2017.09.12 BTCUSD 2017.09.12D19:40:06.109804000 2017.09.12D19:40:06.109802000 MTGX B    0.6165772 480.3795 U      1       
2017.09.12 BTCUSD 2017.09.12D19:40:06.109804000 2017.09.12D19:40:06.109802000 MTGX S    0.1519185 588.6031 U      1       
..
q)meta Quote
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
action  | c    
snapshot| b
```