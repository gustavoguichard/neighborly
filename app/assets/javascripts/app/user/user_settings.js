App.views.User.addChild('UserSettings', _.extend({
  el: '#user_settings',

  activate: function(){
    that = this;
    $(".display_me input[type='radio']").change(function(event){
      that.reloadPreview(event.currentTarget);
      that.reloadInputs(event.currentTarget);
    });

    this.reloadPreview($(".display_me input[type='radio']:checked"));
    this.reloadInputs($(".display_me input[type='radio']:checked"));
  },


  reloadInputs: function(element) {
    var profile_type = $(element).val();
    $('.personal-field, .company-field').hide();

    if(profile_type == 'personal'){
      $('.personal-field').fadeIn(400);
    } else {
      $('.company-field').fadeIn(400);
    }
  },

  reloadPreview: function(element) {
    var profile_type = $(element).val();
    $('#profile_preview .preview').hide();

    if(profile_type == 'personal'){
      $('#profile_preview .personal_preview').fadeIn(400);
    } else {
      $('#profile_preview .company_preview').fadeIn(400);
    }
  }

}));
