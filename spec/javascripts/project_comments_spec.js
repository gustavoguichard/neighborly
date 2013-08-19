describe("ProjectComments", function() {
  var view;
  var parentView = { on: function() {} };

  beforeEach(function() {
    spyOn(window, "setTimeout");
    view = new App.views.Project.views.ProjectComments({parent: parentView, el: $('<div><div id="tab">foo</div><div id="emptyTab"></div></div>')});
  });

  describe("#activate", function(){
    it("should bind the setTimeout", function() {
     expect(window.setTimeout).wasCalledWith(view.replaceCommentsCount, 4000);
    });
  });
});
