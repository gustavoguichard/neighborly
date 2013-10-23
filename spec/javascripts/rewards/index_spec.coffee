describe "Rewards.Index", ->
  beforeEach ->
    $(document.body).append $('<div>').attr('data-rewards-path', '/projects/X/rewards').addClass('rewards')
    @view = new Neighborly.Rewards.Index()

  describe "#initialize", ->
    it 'should call load method', ->
      spyOn(@view, 'load')
      @view.initialize()
      expect(@view.load).toHaveBeenCalled()

  describe "#load", ->
    it 'should call project rewards url', ->
      spyOn($, 'ajax')
      @view.load()
      expect($.ajax.mostRecentCall.args[0]["url"]).toEqual("/projects/X/rewards")

