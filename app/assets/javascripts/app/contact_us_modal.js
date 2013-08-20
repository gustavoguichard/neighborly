App.addChild('ContactUsModal', {
  el: '#contactUsModal',

  events: {
    'blur input' : 'checkInput'
  },

  checkInput: function(event){
    var all_valid = false;

    if($('#contactUsModal input#name').val().length > 5){
      all_valid = true;
      $('#contactUsModal input#name').addClass('ok').removeClass('error');
    } else {
      all_valid = false;
      $('#contactUsModal input#name').addClass('error').removeClass('ok');
    }

    if($('#contactUsModal input#email').val().length > 10){
      all_valid = true
      $('#contactUsModal input#email').addClass('ok').removeClass('error');
    } else {
      all_valid = false;
      $('#contactUsModal input#email').addClass('error').removeClass('ok');
    }

    if(all_valid) {
      $('#contactUsModal input[type=submit]').attr('disabled', false);
    } else {
      $('#contactUsModal input[type=submit]').attr('disabled', 'disabled');
    }
  }
});
