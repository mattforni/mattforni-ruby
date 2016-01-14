//= require angular
//= require jquery
//= require jquery_ujs

var finance = angular.module('finance', []);

function dismissOverlay() {
  $('div#message-wrapper').slideUp(100);
  $('div#overlay').fadeOut(function() {
    $('div#overlay').addClass('dismissed');
  });
}

$( document ).ready(function() {
  if (!$('div#overlay').hasClass('dismissed')) {
    setTimeout(dismissOverlay, 5000);
  }

  $('div.external-logo').hover(function() {
    $(this).addClass('hover');
  }, function() {
    $(this).removeClass('hover');
  });

  $('div#overlay').click(function() {
    dismissOverlay();
  });
});

