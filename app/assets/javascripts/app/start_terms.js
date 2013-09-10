App.addChild('StartTerms', {
  el: '#start_terms',

  events: {
    'click input#accepted_terms': 'toggleSubmit'
  },

  activate: function(){
    this.toggleSubmit()
  },

  toggleSubmit: function(){
    if(this.$('input#accepted_terms').is(':checked')){
      this.$('.send a').attr('href', this.$('.send a').data('url')).removeClass('disabled')
    } else {
      this.$('.send a').attr('href', '#').addClass('disabled')
    }
  }
});


