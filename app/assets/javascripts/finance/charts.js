//= require jquery.flot
//= require jquery.flot.time

const CHART_OPTIONS = {
    series: {
        lines: {
            fill: true,
            fillColor: 'rgba(37, 114, 255, 0.25)'
        }
    },
    xaxis: {
        mode: 'time',
    },
    yaxis: {
        minTickSize: 1,
        position: 'right'
    }
}

function HistoricalChart() {
    const BASE_URL = '/finance/historical';
    const CHART_SELECTOR = 'div#chart';
    const DEFAULT_PERIOD = 'one_month';
    const SELECTED_CLASS = 'selected';

    var locked = false;
    var priceData = {};
    putData(
        gon.period,
        getDate(),
        {
            max: gon.max,
            min: gon.min,
            time_series_data: gon.time_series_data
        }
    );

    function cachedData(period, date) {
        return priceData[period] && priceData[period][date];
    }

    function getData(period, render) {
        if (locked) { return; }
        locked = true;

        if (!period || typeof(period) !== "string") { period = DEFAULT_PERIOD; }
        if (!render || typeof(render) !== "boolean") { render = false; }

        var date = getDate();
        var cached = cachedData(period, date);
        if (cached) {
            if (render) { renderData(cached, period); }
            locked = false;
            return cached;
        }

        $.ajax({
            data: { format: 'json' },
            dataType: 'json',
            type: 'GET',
            url: BASE_URL+'/'+gon.symbol+'/'+period
        }).complete(function() {
            locked = false;
        }).error(function () {
            // TODO error handling
        }).success(function(data, textStatus, jqXHR) {
            putData(period, date, data);
            if (render) { renderData(data, period); }
        });
    }

    function getDate() {
        var date = new Date();
        return date.getMonth()+'/'+date.getDay()+'/'+date.getYear();
    }

    function formatData(data) {
        return {
            color: '#2572ff',
            data: data
        };
    }

    function putData(period, date, data) {
        if (!priceData.hasOwnProperty(period)) { priceData[period] = {}; }
        priceData[period][date] = data;
    }

    function renderData(data, period) {
        CHART_OPTIONS.yaxis.max = data.max + 1;
        CHART_OPTIONS.yaxis.min = data.min - 1 < 0 ? 0 : data.min - 1;
        $.plot(CHART_SELECTOR, [formatData(data.time_series_data)], CHART_OPTIONS);
        $('div.period').removeClass(SELECTED_CLASS);
        $('div.period#'+period).addClass(SELECTED_CLASS);
    }

    return {
        getData: getData
    };
}

$(document).ready(function() {
    if (typeof gon !== 'undefined') {
        var chart = new HistoricalChart();
        chart.getData(gon.period, true);

        $('div.period').click(function() {
            chart.getData($(this).data('value'), true);
        });
    }
});

