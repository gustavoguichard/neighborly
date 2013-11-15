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
          items: ".sortable"
          start: jasmine.any(Function)
          stop: jasmine.any(Function)
          update: jasmine.any(Function)

  describe "#loadForm", ->
    event =
      preventDefault: ->
      currentTarget: '.reward a.edit'

    beforeEach ->
      $('.rewards').html($('<div>').addClass('reward').html($('<a class="edit" data-element=".edit-reward-form" data-path="/edit">')))

      spyOn event, 'preventDefault'
      spyOn $, 'ajax'
      spyOn($.fn, 'addClass')
      spyOn($.fn, 'html')
      @view.loadForm event

    it "should call edit reward url", ->
      expect($.ajax.mostRecentCall.args[0]["url"]).toEqual("/edit")

    it "should add editing class", ->
      expect($.fn.addClass).wasCalledWith('editing')

    it "should remove old html", ->
      expect($.fn.html).wasCalledWith('')

    it "should call preventDefault", ->
      expect(event.preventDefault).wasCalled()

  describe "#cancel", ->
    event =
      preventDefault: ->
      currentTarget: '.reward a.cancel'

    beforeEach ->
      spyOn event, 'preventDefault'
      spyOn($.fn, 'removeClass')
      spyOn($.fn, 'fadeOut').andReturn($.fn)
      @view.cancel event

    it "should call fadeOut", ->
      expect($.fn.fadeOut).wasCalled()

    it "should remove editing class", ->
      expect($.fn.removeClass).wasCalledWith('editing')

    it "should call preventDefault", ->
      expect(event.preventDefault).wasCalled()
