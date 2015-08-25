//= require highcharts

function spreadGraph(container) {
    $(container).highcharts({
        chart: {
            animation: false,
            type: 'columnrange',
            inverted: true
        },
        title: {
            text: null
        },
        xAxis: {
           lineWidth: 0,
           minorGridLineWidth: 0,
           lineColor: 'transparent',
           labels: {
               enabled: false
           },
           minorTickLength: 0,
           tickLength: 0
        },
        yAxis: {
           gridLineColor: 'transparent',
           lineWidth: 0,
           max: 14.23,
           min: 10.24,
           minorGridLineWidth: 0,
           lineColor: 'transparent',
           labels: {
               enabled: false
           },
           minorTickLength: 0,
           tickLength: 0,
            title: {
                text: null
            }
        },
        tooltip: {
            enabled: false
        },
        plotOptions: {
            columnrange: {
                dataLabels: {
                    enabled: true,
                    formatter: function () {
                        return '$'+this.y;
                    }
                }
            },
            series: {
                animation: false,
                dataLabels: {
                    align: 'center'
                },
                states: {
                    hover: {
                        enabled: false
                    }
                }
            }
        },
        legend: {
            enabled: false
        },
        series: [{
            data: [
                [10.24, 14.23]
            ]
        }]

    });
}

function toggleVisibility(selector) {
  $(selector).toggleClass('visible');
}

$( document ).ready(function() {
  $('div.portfolio a').click(function(event) {
    event.stopPropagation();
  });

  $('tr.position').click(function() {
    toggleVisibility('tr.'+$(this).attr('id')+'-holding');
  });

  $('div.portfolio-name').mouseenter(function() {
    toggleVisibility('div#'+$(this).attr('id')+'-options');
  });

  $('div.portfolio-name').mouseleave(function() {
    toggleVisibility('div#'+$(this).attr('id')+'-options');
  });
});

