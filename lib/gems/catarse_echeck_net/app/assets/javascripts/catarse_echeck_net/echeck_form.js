App.addChild('EcheckForm', {
  el: '#catarse_echeck_net_form',

  events: {
    'submit form#echeck_form': 'submitEcheck'
  },

  activate: function() {
    var self = this;
    var $submit_path = this.$('form#echeck_form').prop('action');
    if(this.$('#user_email_on_check').length > 0) {
      this.$('#user_email_on_check').focusout(function(){self.echeck_ok()});
    }

    this.$('#routing_number').focusout(function(){self.echeck_ok()});
    this.$('#account_number').focusout(function(){self.echeck_ok()});
    this.$('#account_holder_name').focusout(function(){self.echeck_ok()});
    this.$('form#echeck_form .accept input').change(self.echeck_ok);

  },

  submitEcheck: function(e) {
    e.preventDefault();

    if(this.echeck_ok()) {
      this.$('form#echeck_form .submit input').addClass('disabled');
      this.$('form#echeck_form .submit input').val('Processing...');

      var echeck_data = {
        'routing_number': this.$('#routing_number').val(),
        'account_number': this.$('#account_number').val(),
        'bank_name': this.$('#bank_name').val(),
        'account_holder_name': this.$('#account_holder_name').val(),
        'user_email': $('#user_email').val()
      }

      $.post($('form#echeck_form').prop('action'), echeck_data, function(response){
        if(response.process_status == 'ok') {
          var thank_you_path = $('#project_review').data('thank-you-path')
          location.href= thank_you_path;
        } else {
          $('.checkError p.errorName').text(response.message);
          $('.checkError').fadeIn(300);
          $('form#echeck_form .submit input').removeClass('disabled');
          $('form#echeck_form .submit input').val('Confirm');
        }
      }, 'json').error(function(){
        $('.checkError p.errorName').text('The back already confirmed, if you can do another back please refresh the page or go back to project page :)');
        $('.checkError').fadeIn(300);
      })
    }

    return false;
  },

  replaceAll: function(string, token, newtoken) {
    while (string.indexOf(token) != -1) {
      string = string.replace(token, newtoken);
    }
    return string;
  },

  check_routing_number: function(id) {
    number = $.trim($(id).val());
    if(number.length == 9) {
      return $.getJSON('/payment/echeck_net/check_routing_number',{number: number}, function(response){
        if(response.ok) {
          $(id).addClass("valid").removeClass("error");
          $('#bank_name').val(response.bank_name);
          return true;
        } else {
          $(id).addClass("error").removeClass("valid");
          return false;
        }
      });
    } else {
      $(id).addClass("error").removeClass("valid");
      return false;
    }
  },

  echeck_ok: function() {
    var all_ok = true;

    if($('#user_email_on_check').length > 0) {
      if(!this.ok('#user_email_on_check')) {
        all_ok = false;
      }
    }
    if(!this.check_routing_number($('#routing_number'))) {
      all_ok = false;
    }
    if(!this.ok('#account_number')) {
      all_ok = false;
    }
    if(!this.ok('#account_holder_name')) {
      all_ok = false;
    }

    if(all_ok){
      this.$('form#echeck_form .submit input').removeClass('disabled');
    } else {
      this.$('form#echeck_form .submit input').addClass('disabled');
    }

    return all_ok;
  },

  ok: function(id){
    var value = $.trim(this.replaceAll($(id).val(),'_', ''))
    //var value = $.trim($(id).val())
    if(value && value.length > 0){
      $(id).addClass("valid").removeClass("error");
      return true;
    } else {
      $(id).addClass("error").removeClass("valid");
      return false;
    }
  }
});
