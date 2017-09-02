Quote:flip `time`timeExch`sym`exch`side`price`qty`action`snapshot!"ppsscffcb"$\:();

/q)meta Quote
/c       | t f a
/--------| -----
/time    | p         / time that quote was created by system
/timeExch| p         / time that quote was create by exch (e.g. TransactTime)
/sym     | s         / instrument
/exch    | s         / exchange
/side    | c         / bid or offer
/price   | f         / price
/qty     | f         / quantity
/action  | c         / N(ew), D(elete), U(pdate)
/snapshot| b         / 1b clears quotebook, 0b upserts