var App = window.App = Skull.View.extend({
  el: 'html',

  events: {
    "click a.my_profile_link" : "toggleMenu"
  },

  beforeActivate: function(){
    this.$search = this.$('#pg_search');
    this.router = new Backbone.Router;
  },

  activate: function(){
    this.$(".best_in_place").best_in_place();
    this.$dropdown = this.$('.dropdown.user');
    this.flash();
    this.notices();
    this.privacyAndTermsModals();
    Backbone.history.start({pushState: false});
    this.$('input[data-mask]').each(this.maskElement);
    $('.use_popover_bottom').popover({placement: 'bottom', trigger: 'click'});
  },

  flash: function() {
    var that = this;
    this.$flash = this.$('.flash');

    setTimeout( function(){ that.$flash.slideDown('slow') }, 100)
    if( ! this.$('.flash a').length) setTimeout( function(){ that.$flash.slideUp('slow') }, 16000)
    $(window).click(function(){ that.$('.flash a').slideUp() })
  },

  notices: function() {
    var that = this;
    setTimeout( function(){ this.$('.notice-box').fadeIn('slow') }, 100)
    if(this.$('.notice-box').length) setTimeout( function(){ that.$('.notice-box').fadeOut('slow') }, 16000)
    $('.notice-box a.notice-close').on('click', function(){ that.$('.notice-box').fadeOut('slow') })
  },

  maskElement: function(index, el){
    var $el = this.$(el);
    $el.mask($el.data('mask') + '');
  },

  toggleMenu: function(){
    this.$dropdown.slideToggle('fast');
  },

  privacyAndTermsModals: function(){
    loading = $('.bootstrap-twitter .loading.hide').clone().removeClass('hide');
    $('#termsModal').on('show', function () {
      $.ajax({
        url: $(".termsModalLink").data('url'),
        beforeSend: function(){},
        success: function(txt){
          $("#termsModal .modal-body").html(txt);
        }
      });
    });
    $('#privacyModal').on('show', function () {
      $.ajax({
        url: $(".privacyModalLink").data('url'),
        beforeSend: function(){},
        success: function(txt){
          $("#privacyModal .modal-body").html(txt);
        }
      });
    });

    $('#termsModal').on('hide', function () {
      $("#termsModal .modal-body").html(loading);
    });
    $('#privacyModal').on('hide', function () {
      $("#privacyModal .modal-body").html(loading);
    });
  }

});

$(function(){
  var app = window.app = new App();
});
