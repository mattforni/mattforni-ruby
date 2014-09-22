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
  if (!$('div#overlay').hasClass('dismissed')) {
    setTimeout(dismissOverlay, 5000);
  }

  $('div.social-logo img').hover(function() {
    $(this).addClass('hover');
  }, function() {
    $(this).removeClass('hover');
  });

  $('div#overlay').click(function() {
    dismissOverlay();
  });
});

