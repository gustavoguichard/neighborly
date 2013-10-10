describe "Projects.Index", ->
  beforeEach ->
    $(document.body).append $('<div>').addClass('home-page').html(
      $('<select data-projects-path="/projects/near">').addClass('change-city').html('<option value="test" selected="selected">Test</option>')
    )
    @view = new Neighborly.Projects.Index()

  describe "#ChangeCity", ->
    it "should call near projects url", ->
      spyOn($, 'ajax')
      @view.changeCity()
      expect($.ajax.mostRecentCall.args[0]["url"]).toEqual("/projects/near?location=test")
