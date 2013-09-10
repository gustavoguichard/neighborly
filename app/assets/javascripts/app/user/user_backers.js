App.views.User.addChild('UserBackers', _.extend({
  el: '#user_backed_projects',
  events: {
    "click #badge_embed_html": "selectTarget",
    "click a.badgesModal": "clickBadge"
  },

  activate: function(){
    var that = this;
    this.$loader = this.$(".loading img");
    this.$loaderDiv = this.$(".loading");
    this.$results = this.$(".results");
    this.path = this.$el.data('path');
    this.filter = {};
    this.setupScroll();
    this.parent.on('selectTab', function(){
      if(that.$el.is(':visible')){
        that.fetchPage();
      }
    });

    this.data_url = '';
    this.badges();
  },

  selectTarget: function(event){
    event.preventDefault()
    $(event.target).select()
  },

  clickBadge: function(e){
    $('#badgesModal').data('project-url', $(e.target).parent().data('url'));
    $('#badgesModal').modal('show')
  },

  badges: function(){
    var context = '.bootstrap-twitter #badgesModal .modal-body'
    $('#badgesModal').on('show', function (e) {
      $(context + ' .loading').hide()
      $(context + ' .base_code a').attr('href', $('#badgesModal').data('project-url'))
      var code = $(context + ' .base_code').html()
      $(context + " #badge_embed_html").val(code)

      $(context + ' .modal-content').show()
    });


    $('#badgesModal').on('hide', function () {
      $(context + ' .loading').show()
      $(context + ' .modal-content').hide()
    });
  }

}, Skull.InfiniteScroll));

