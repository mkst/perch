
/FUNC[sizes;prices;qty]
vwap:{$[z>last s:sums x;0n;wavg[deltas z&s;y]]}; / cumulatively sweep book until requested amount amount found
worst:{y first where z<=sums x};                 / cumulatively sweep book until requested amount amount found, use price at this level
full:{y first where z<=x};                       / search book until requested amount amount found

sweep:{[FUNC;BOOK;SIZE] select time, bidpx:FUNC[;;SIZE].'flip (bidqty;bidpx), askpx:FUNC[;;SIZE].'flip (askqty;askpx) from BOOK };

sweepVWAP:sweep[vwap;;]
sweepWORST:sweep[worst;;]
sweepFULL:sweep[full;;]

/ examples
/q)worst[;;4000000].(1000000 3000000 5000000 1e+07;1.16543 1.16514 1.1649 1.16438)
/1.16514
/q)full[;;4000000].(1000000 3000000 5000000 1e+07;1.16543 1.16514 1.1649 1.16438)
/1.1649
/q)vwap[;;4000000].(1000000 3000000 5000000 1e+07;1.16543 1.16514 1.1649 1.16438)
/1.165212