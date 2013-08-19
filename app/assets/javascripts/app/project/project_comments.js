App.views.Project.addChild('ProjectComments', {
  el: '#project_comments',

  activate: function(){
    this.render();
  },

  render: function(){
    replaceCommentsCount = function() {
      $('span#countNumber').text($('a#disqusCount').text().split(" ")[0]);
      $('.commentsCount').show();
    }
    setTimeout('replaceCommentsCount()', 4000);
  }
});
