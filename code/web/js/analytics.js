function plot(data, layout, div) {
  DATA = data;
  // clear previous plot
  Plotly.purge(div);
  // get div
  var chart = document.getElementById(div);
  // plot
	Plotly.plot( document.getElementById(div), data, layout, {displayModeBar: false} );
 // resize chart on window resize
 window.onresize = function() { Plotly.Plots.resize(chart); };
}

function callback(error, csvs) {

  if (error) throw error; // TODO: handle properly

  var data = [];

  var maxdepth = 0;
  csvs.forEach(function(rows) {
    //
    if (rows.columns.indexOf("bidpx") != -1)
    {
      // prices
      var time = rows.map(function(row) { return row["time"].replace("D","T")});
      var bids = rows.map(function(row) { return row["bidpx"]});
      var asks = rows.map(function(row) { return row["askpx"]});
      data.push({x:time, y:bids, name:"bidpx"});
      data.push({x:time, y:asks, name:"askpx"});
    } else if (rows.columns.indexOf("biddepth") > -1) {
      // depth
      var time = rows.map(function(row) { return row["time"].replace("D","T")});
      var bids = rows.map(function(row) { return row["biddepth"]});
      var asks = rows.map(function(row) { return row["askdepth"]});
      data.push({x:time, y:bids, name:"biddepth", yaxis:"y3", type:"bar"});
      data.push({x:time, y:asks, name:"askdepth", yaxis:"y3", type:"bar"});
    } else if (rows.columns.indexOf("spread") > -1) {
      var time = rows.map(function(row) { return row["time"].replace("D","T")});
      var spread = rows.map(function(row) { return row["spread"]});
      data.push({x:time, y:spread, name:"spread", yaxis:"y2"});
    } else {
      // trades
      var time = rows.map(function(row) { return row["time"].replace("D","T")});
      var price = rows.map(function(row) { return row["price"]});
      var names = rows.map(function(row) { return "qty: " + row["qty"] + "<br>id:" + row["id"]});
      data.push({x:time, y:price, text:names, name:"trade", mode: "markers", type: "scatter"});
    }
  })
  // simple layout
  var layout = { margin: { t: 0 },
                 xaxis: { gridcolor: '#333'},
                 yaxis: { domain:[0.2, 1] },
                 yaxis2: { domain:[0, 0.07] },
                 yaxis3: { domain:[0.08, 0.15] },
                 plot_bgcolor: '#212121',
                 paper_bgcolor:'#212121',
                 font: { color:'#EEE'},
               };
  // plot data
  plot(data, layout, 'chart')
}

function processForm(form) {
  var inputs = form.getElementsByTagName("input");
  var symbol = inputs['symbol'].value;
  var type = inputs['type'].value;
  var amount = inputs['amount'].value;

  if (symbol == '' || type == '') {
    return
  }
  if (amount == '' && type != 'BBO') {
    return
  }
  var req_prices = '';
  if(type == 'BBO'){
    req_prices = 'select from BBO where sym=`' + symbol;
  } else {
    req_prices = 'sweep' + type + '[;'+ amount +'] select from Book where sym=`' + symbol;
  }
  var req_trades = 'select from Trade where sym=`' + symbol;
  var req_depths = 'select biddepth:avg sum each bidqty, askdepth:avg sum each askqty by 0D00:01 xbar time from Book where sym=`' + symbol;
  var req_spreads = 'select time, spread:askpx-bidpx from ' + req_prices;
  // add to queue
  d3.queue(2)
    .defer(d3.csv, 'csv?query "'+ req_prices + '"')
    .defer(d3.csv, 'csv?query "'+ req_spreads + '"')
    .defer(d3.csv, 'csv?query "'+ req_trades + '"')
    .defer(d3.csv, 'csv?query "'+ req_depths + '"')
    .awaitAll(callback);
}