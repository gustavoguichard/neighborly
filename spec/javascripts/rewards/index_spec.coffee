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

  describe "#sortable", ->
    beforeEach ->
      spyOn @view.$rewards, "sortable"

    describe "when I can update rewards", ->
      beforeEach ->
        spyOn(@view.$rewards, "data").andReturn true
        @view.sortable()

      it "should test can_update", ->
        expect(@view.$rewards.data).wasCalledWith "can-update"

      it "should call sortable", ->
        expect(@view.$rewards.sortable).wasCalledWith
          axis: "y"
          placeholder: "sortable-highlight"
          start: jasmine.any(Function)
          stop: jasmine.any(Function)
          update: jasmine.any(Function)
