App.addChild('CreditCardNetForm', {
  el: '#catarse_credit_card_net_form',

  events: {
    'submit form#credit_card_form': 'submitCard'
  },

  activate: function() {
    var self = this;

    this.$('#billing_name').focusout(function(){self.card_ok()})
    this.$('#card_number').focusout(function(){self.card_ok()})
    this.$('#card_code').focusout(function(){self.card_ok()})
    this.$('form#credit_card_form .accept input').change(self.card_ok);
    this.$('#card_number').mask("9999999999999?999",{placeholder:""});
    this.$('#card_code').mask("999?9",{placeholder:""});
    this.$('.AuthorizeNetSeal').html($('.seal-original .AuthorizeNetSeal').html())
  },

  submitCard: function(e) {
    e.preventDefault();

    if(this.card_ok()) {

      $('form#credit_card_form .submit input').addClass('disabled');
      $('form#credit_card_form .submit input').attr('disabled', 'disabled');
      $('form#credit_card_form .submit input').val('Processing...');

      card_data = {
        'card_number': this.$('#card_number').val(),
        'card_code': this.$('#card_code').val(),
        'card_month': this.$('#card_month').val(),
        'card_year': this.$('#card_year').val(),
        'billing_name': this.$('#billing_name').val(),
        'user_email': $('#user_email').val()
      }

      $.post($('form#credit_card_form').prop('action'), card_data, function(response){
        console.log(response)
        if(response.process_status == 'ok') {
          var thank_you_path = $('#project_review').data('thank-you-path')
          location.href= thank_you_path;
        } else {
          $('.checkError p.errorName').text(response.message);
          $('.checkError').fadeIn(300);
          $('form#credit_card_form .submit input').removeClass('disabled');
          $('form#credit_card_form .submit input').attr('disabled', false);
          $('form#credit_card_form .submit input').val('Confirm');
        }
      }, 'json').error(function(){
        $('.checkError p.errorName').text('The back already confirmed, if you can do another back please refresh the page or go back to project page :)');
      $('.checkError').fadeIn(300);
      });
    }
  },

  card_ok: function() {
    all_ok = true;
    if(!this.valid_billing_name()) {
      all_ok = false;
    }
    if($('#user_email').length > 0) {
      if(!this.ok('#user_email')) {
        all_ok = false;
      }
    }
    if(!this.ok('#card_number')) {
      all_ok = false;
    }
    if(!this.ok('#card_code')) {
      all_ok = false;
    }

    if(!$('form#credit_card_form .accept input').is(':checked')){
      all_ok = false
      $('form#credit_card_form .accept label').addClass('error').removeClass('valid');
    }

    if(all_ok){
      $('form#credit_card_form .submit input').removeClass('disabled');
    } else {
      $('form#credit_card_form .submit input').addClass('disabled');
    }
    return all_ok;
  },

  valid_billing_name: function() {
    input = $('#billing_name')
    name_total = input.val().split(" ").length
    if(name_total > 1) {
      $(input).addClass("valid").removeClass("error");
      return true;
    } else {
      $(input).addClass("error").removeClass("valid");
      return false;
    }
  },

  ok: function(id){
    var value = $.trim(this.replaceAll($(id).val(),'_', ''))
    if(value && value.length > 0){
      $(id).addClass("valid").removeClass("error");
      return true;
    } else {
      $(id).addClass("error").removeClass("valid");
      return false;
    }
  },

  replaceAll: function(string, token, newtoken) {
    while (string.indexOf(token) != -1) {
      string = string.replace(token, newtoken);
    }
    return string;
  }
});
