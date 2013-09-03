App.addChild('PayPalFormCuston', _.extend({
  el: '#catarse_paypal_express_form',

  events: {
    'click input[type=submit]': 'onSubmitToPayPal',
    'change form .accept input' : 'onCheck'
  },

  onCheck: function() {
    if(this.$('form .accept input').is(':checked')) {
      this.$('.submit input').removeClass('disabled');
    } else {
      this.$('.submit input').addClass('disabled');
    }
  },

  onSubmitToPayPal: function(){
    this.$('.submit input').addClass('disabled');

    if(this.$('form .accept input').attr('checked')) {
      $(this)[0].submit();
    }
  }

}));
