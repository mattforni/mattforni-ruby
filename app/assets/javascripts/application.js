//= require angular
//= require jquery
//= require jquery_ujs
//= require_self
//= require_tree .

var mattforni = angular.module('mattforni', []);

$( document ).ready(function() {
  $("#middle").hover(function() {
    $(this).css("opacity", 1);
  },
  function() {
    $(this).css("opacity", 0.05);
  });
});


