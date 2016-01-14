//= require finance
//= require finance/charts/spread_chart

const HOLDINGS_PATH = 'positions/{id}/holdings'

function toggleVisibility(selector) {
  var visible = $(selector).hasClass('visible');
  $(selector).toggleClass('visible');
  return !visible;
}

var holdings = {};

$(function ready() {
  $('table.portfolio a').click(function(event) {
    event.stopPropagation();
  });

  $('table.portfolio input').click(function(event) {
    event.stopPropagation();
  });

  $('tr.position').click(function() {
    var id = $(this).attr('data-id');
    if (typeof id !== 'string') { return; }

    var row = this;

    // If the holdings have already been fetched
    if (holdings.hasOwnProperty(id)) {
      toggleVisibility('tr.'+$(this).attr('id')+'-holding');
    } else { // Otherwise attempt to fetch the data
      var url = HOLDINGS_PATH.replace('{id}', id);
      $.get(url).done(function success(data) {
        holdings[id] = data;
        $(row).after(data);
        toggleVisibility('tr.'+$(this).attr('id')+'-holding');
      })
    }
  });

  $('div.portfolio-name').hover(function mouseenter() {
    toggleVisibility('div#'+$(this).attr('id')+'-options');
  }, function mouseleave() {
    toggleVisibility('div#'+$(this).attr('id')+'-options');
  });

  $('div#new-menu').hover(function mouseenter() {
    toggleVisibility('div#new-menu-options');
  }, function mouseleave() {
    toggleVisibility('div#new-menu-options'); 
  });
});

