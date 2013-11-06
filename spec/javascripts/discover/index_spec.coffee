describe "Projects.Index", ->
  beforeEach ->
    $(document.body).append $('<div>').addClass('discover-page').attr('data-path', '/discover').html $('<section>').addClass('content')
    @view = new Neighborly.Discover.Index.init()

  describe '#initialize', ->
    beforeEach ->
      spyOn($.fn, 'change')
      spyOn($.fn, 'submit')
      spyOn(@view, 'bindPjaxLoading')
      @view.initialize()

    it 'should call bindPjaxLoading', ->
      expect(@view.bindPjaxLoading).toHaveBeenCalled()

    it 'should bind change event', ->
      expect($.fn.change).toHaveBeenCalledWith(jasmine.any(Function))

    it 'should bind submit event', ->
      expect($.fn.submit).toHaveBeenCalledWith(jasmine.any(Function))

  describe '#process', ->
    beforeEach ->
      @pjax = spyOn($, 'pjax').andReturn ->
      spyOn(@view, 'generateUrl')
      @view.process()

    it 'should bind pjax:send', ->
      expect(@view.generateUrl).toHaveBeenCalled()

    it 'should call pjax', ->
      expect(@pjax).toHaveBeenCalled()

  describe '#generateUrl', ->
    beforeEach ->
      filter = $('<select>').html $("<option value='recommended'>")
      category = $('<select>').html $("<option value='transit'>")
      near = $('<select>').html $("<option value='Kansas City'>")
      tags = [$('<div data-name="tag1">'), $('<div data-name="tag2">')]
      search = $('<input value="something">')
      @url = @view.generateUrl(filter, near, category, tags, search)
      console.log @url

    it 'should return the url', ->
      expect(@url).toEqual('/discover/recommended/near/Kansas City/category/transit/tags/tag1,tag2/search/something')

  describe 'bindPjaxLoading', ->
    beforeEach ->
      spyOn($.fn, 'on')
      @view.bindPjaxLoading()

    it 'should bind pjax:send', ->
     expect($.fn.on).toHaveBeenCalledWith('pjax:send', jasmine.any(Function))

    it 'should bind pjax:complete', ->
     expect($.fn.on).toHaveBeenCalledWith('pjax:complete', jasmine.any(Function))

  describe '#toggleTag', ->
    beforeEach ->
      @event =
        preventDefault: ->
        currentTarget: 'a'

      spyOn($.fn, 'toggleClass')
      spyOn(@event, 'preventDefault')
      spyOn(@view, 'process')
      @view.toggleTag(@event)

    it "should call process function", ->
      expect(@view.process).wasCalled()

    it 'should toggle class to current target', ->
      expect($.fn.toggleClass).toHaveBeenCalledWith('selected')

    it "should call preventDefault", ->
      expect(@event.preventDefault).wasCalled()

