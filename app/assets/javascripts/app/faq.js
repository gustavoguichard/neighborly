App.addChild('FaqPage', {
  el: '#faq_page',


  activate: function(){
    $('dt').css({'cursor': 'pointer'});
    $('dd').hide();

    $('dt').click(function(e){
      var target = e.currentTarget;
      var dd = $($(target).parent().find('dd'))
      if(dd.css('display') == 'none') {
        dd.slideDown('fast');
      } else {
        dd.slideUp('fast');
      }
    });
  }
});

