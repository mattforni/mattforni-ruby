$( document ).ready(function() {
  $('tr.position').click(function() {
    $('tr.'+$(this).attr('id')+'-holding').toggleClass('visible');
  });
});

