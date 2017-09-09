# perch
Not quite a trading _platform_, written in q. Very unfinished.

_"...Look on my works, ye mighty, and despair!"_

## TODO

 - [ ] book builder (convert quotes into books)
 - [ ] pool builder (aggregate books into pools)
 - [ ] order manager
 - [ ] HTML5 front-end for order manager
 - [ ] investigate alternative messaging protocol (e.g. zeromq)

## Tutorial

**Setup environment/paths**
    source scripts/env.sh

**Start up publisher**

    q32 code/kdb/test/publisher.q

**Start up logger**

    q32 code/kdb/procs/logger/logger_init.q -config config/examples/logger.cfg

**Start up rdb (disk)**

    q32 code/kdb/procs/rdbdisk/rdbdisk_init.q -config config/examples/rdbdisk.cfg

**Roll log to HDB**

    q32 code/kdb/scripts/roll.q -log /tmp/log/20170909 -hdb /tmp/rolled/hdb -cov /rmp/rolled/api

**Read data from HDB**

```
q)\l /data/api
q)select from Coverage
date       table sym    exch start                         end                           num   path            
---------------------------------------------------------------------------------------------------------------
2017.09.09 Quote BTCEUR KRKN 2017.09.09D10:25:35.628962000 2017.09.09D10:53:54.029092000 16674 :/tmp/rolled/hdb
2017.09.09 Quote BTCUSD KRKN 2017.09.09D10:25:35.628962000 2017.09.09D10:53:54.029092000 16528 :/tmp/rolled/hdb
2017.09.09 Quote EURUSD KRKN 2017.09.09D10:25:35.628962000 2017.09.09D10:53:54.029092000 16698 :/tmp/rolled/hdb
2017.09.09 Quote BTCUSD BITS 2017.09.09D10:25:36.729101000 2017.09.09D10:53:55.129028000 16516 :/tmp/rolled/hdb
2017.09.09 Quote BTCEUR BITS 2017.09.09D10:25:36.729101000 2017.09.09D10:53:55.129028000 16524 :/tmp/rolled/hdb
2017.09.09 Quote EURUSD BITS 2017.09.09D10:25:36.729101000 2017.09.09D10:53:55.129028000 16260 :/tmp/rolled/hdb
2017.09.09 Quote EURUSD MTGX 2017.09.09D10:25:38.929028000 2017.09.09D10:53:56.229095000 18548 :/tmp/rolled/hdb
2017.09.09 Quote BTCEUR MTGX 2017.09.09D10:25:38.929028000 2017.09.09D10:53:56.229095000 18556 :/tmp/rolled/hdb
2017.09.09 Quote BTCUSD MTGX 2017.09.09D10:25:38.929028000 2017.09.09D10:53:56.229095000 18396 :/tmp/rolled/hdb
q)extract select from Coverage where date=2017.09.09,sym=`BTCUSD,exch=`MTGX
date       sym    exch time                          timeExch                      side price       qty      action snapshot
----------------------------------------------------------------------------------------------------------------------------
2017.09.09 BTCUSD MTGX 2017.09.09D10:25:38.929028000 2017.09.09D10:25:38.929024000 S    0.6676175   869.4906 U      1       
2017.09.09 BTCUSD MTGX 2017.09.09D10:25:38.929028000 2017.09.09D10:25:38.929024000 S    0.143963    51.0387  U      1       
2017.09.09 BTCUSD MTGX 2017.09.09D10:25:38.929028000 2017.09.09D10:25:38.929024000 S    0.2696229   420.2817 N      0       
2017.09.09 BTCUSD MTGX 2017.09.09D10:25:38.929028000 2017.09.09D10:25:38.929024000 B    0.1422971   275.2264 N      0       
2017.09.09 BTCUSD MTGX 2017.09.09D10:25:38.929028000 2017.09.09D10:25:38.929024000 S    0.08801059  202.7525 N      0      
..
```