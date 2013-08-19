App.views.Project.addChild('ProjectComments', {
  el: '#project_comments',

  activate: function(){
    window.setTimeout(this.replaceCommentsCount, 4000);
  },

  replaceCommentsCount: function(){
    $('span#countNumber').text($('a#disqusCount').text().split(" ")[0]);
    $('.commentsCount').show();
  }
});
