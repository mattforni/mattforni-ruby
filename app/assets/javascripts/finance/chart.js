//= require jquery.flot
//= require jquery.flot.time

const DEFAULT_PERIOD = 'one_month'
const HISTORICAL_URL = '/finance/historical';
const CHART_OPTIONS = {
    xaxis: {
        mode: 'time',
        minTickSize: [0.5, 'month']
    }
}

var getHistoricalData = function(symbol, period) {
    period = period || DEFAULT_PERIOD
    $.ajax({
        accepts: 'json',
        data: { format: 'json' },
        dataType: 'json',
        type: 'GET',
        url: HISTORICAL_URL+'/'+symbol+'/'+period
    }).success(function(data, textStatus, jqXHR) {
        renderChart([data]);
    });
}

var renderChart = function(data) {
    $.plot('div#chart', data, CHART_OPTIONS); 
}

if (gon) {
  $(document).ready(function() { renderChart([gon.series]); });
} else {
  alert('Charting is broken.');
}

