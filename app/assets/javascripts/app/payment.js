App.addChild('Payment', _.extend({
  el: '#main_content[data-action="create"][data-controller-name="backers"] #payment',

  events: {
    'change .payment_menu input' : 'showPaymentContent'
  },

  showPaymentContent: function(e){
    $('#info_box strong.total_value').text($(e.target).data('value-with-taxs'));
    $('.payments_type').hide();
    payment = '.payments_type#' + $(e.target).val() + '_payment'
    $(payment).fadeIn();

    if($(payment).data('path')){
      $.get($(payment).data('path')).success(function(data){
        $(payment).html(data);
      });
    }
  },

  activate: function(){
    this.$('.payment_menu input:first').attr('checked', true);
    this.showPaymentContent({target: '#payment_method_credit_card_net'});

    $('.icon-info-sign').on('click', function(){
      $('.info_more').slideToggle();
    });
  },

  updatePaymentMethod: function() {
    var $selected_tab = this.$('#payment_menu a.selected');
    $.post(this.$el.data('update-info-path'), {
      backer: {
        payment_method: $selected_tab.prop('id')
      }
    })
  }
}));

