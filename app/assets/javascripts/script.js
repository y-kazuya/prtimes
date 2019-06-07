$(document).on('turbolinks:load', function(){
    var h = $(window).height();
    $('#main-contents').css('display','none');
    $('#loader-bg ,#loader').height(h).css('display','block');

  })

  $(window).load(function () {
    $('#loader-bg').delay(900).fadeOut(800);
    $('#loader').delay(600).fadeOut(300);
    $('#main-contents').css('display', 'block');
    });