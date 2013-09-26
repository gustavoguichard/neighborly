App.addChild('ProjectForm', _.extend({
  el: 'form#project_form',

  events: {
    'blur input' : 'checkInput',
  },

  activate: function(){
    this.setupForm();

    $('#project_about, #project_budget').markItUp(myMarkdownSettings);

    $('#project_tag_list').tagsInput({
      autocomplete_url: $('.tags_path').data('url'),
      width:'410px',
      height: '65px'
    });
  }

}, Skull.Form));

// Put subview here to avoid dependency issues

App.views.ProjectForm.addChild('VideoUrl', _.extend({
  el: 'input#project_video_url',

  events: {
    'timedKeyup' : 'checkVideoUrl'
  },

  checkVideoUrl: function(){
    var that = this;
    $.get(this.$el.data('path') + '?url=' + encodeURIComponent(this.$el.val())).success(function(data){
      if(!data || !data.video_id){
        that.$el.trigger('invalid');
      }
    });
  },

  activate: function(){
    this.setupTimedInput();
  }
}, Skull.TimedInput));

App.views.ProjectForm.addChild('Permalink', _.extend({
  el: 'input#project_permalink',

  events: {
    'timedKeyup' : 'checkPermalink'
  },

  checkPermalink: function(){
    var that = this;
    if(this.re.test(this.$el.val())){
      $.get('/' + this.$el.val()).complete(function(data){
        if(data.status != 404){
          that.$el.trigger('invalid');
        }
      });
    }
  },

  activate: function(){
    this.re = new RegExp(this.$el.prop('pattern'));
    this.setupTimedInput();
  }
}, Skull.TimedInput));

App.addChild('ProjectFormEdit', {
  el: '#project_edit',

  activate: function(){
    this.$('#project_about, #project_budget, #project_terms').markItUp(myMarkdownSettings);

    $('#project_tag_list').tagsInput({
      autocomplete_url: $('.tags_path').data('url'),
      width:'446px',
      height: '65px'
    });
  }

});
