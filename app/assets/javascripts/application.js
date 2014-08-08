//= require angular
//= require jquery
//= require jquery_ujs
//= require_self
//= require_tree .

var mattforni = angular.module('mattforni', []);

function dismissOverlay() {
  $('div#message-wrapper').slideUp(100);
  $('div#overlay').fadeOut(function() {
    $('div#overlay').addClass('dismissed');
  });
}

$( document ).ready(function() {
  $('#middle').hover(function() {
    $(this).css('opacity', 1);
  },
  function() {
    $(this).css('opacity', 0.05);
  });

  if (!$('div#overlay').hasClass('dismissed')) {
    setTimeout(dismissOverlay, 5000);
  }

  $('div#overlay').click(function() {
    dismissOverlay();
  });
});

