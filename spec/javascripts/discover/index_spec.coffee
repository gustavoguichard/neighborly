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
      @filter = $('<select>').html $("<option selected='true' value='recommended'>").html('Recommended')
      @category = $('<select>').html $("<option selected='true' value='transit'>").html('Transit')
      @near = $('<select>').html $("<option selected='true' value='Kansas City'>").html('Kansas City')
      @tags = [$('<div data-name="tag1">'), $('<div data-name="tag2">')]
      @search = $('<input value="something">')
      spyOn(@view, 'addResultFor')

    describe 'full url', ->
      beforeEach ->
        @url = @view.generateUrl(@filter, @near, @category, @tags, @search)

      it 'should return the url', ->
        expect(@url).toEqual('/discover/recommended/near/Kansas City/category/transit/tags/tag1,tag2/search/something')

      it 'should call addResultFor filter', ->
        expect(@view.addResultFor).toHaveBeenCalledWith('filter', 'Recommended')

      it 'should call addResultFor near', ->
        expect(@view.addResultFor).toHaveBeenCalledWith('near', 'Kansas City')

      it 'should call addResultFor category', ->
        expect(@view.addResultFor).toHaveBeenCalledWith('category', 'Transit')

      it 'should call addResultFor search', ->
        expect(@view.addResultFor).toHaveBeenCalledWith('search', 'something')

    describe 'when near is not present', ->
      beforeEach ->
        spyOn(@view, 'removeResultFor')
        @url = @view.generateUrl(@filter, $('<select>').html($("<option value=''>")), @category, @tags, @search)

      it 'should return the url', ->
        expect(@url).toEqual('/discover/recommended/category/transit/tags/tag1,tag2/search/something')

      it 'should call addResultFor filter', ->
        expect(@view.addResultFor).toHaveBeenCalledWith('filter', 'Recommended')

      it 'should not call addResultFor near', ->
        expect(@view.addResultFor).not.toHaveBeenCalledWith('near', 'Kansas City')

      it 'should call removeResultFor near', ->
        expect(@view.removeResultFor).toHaveBeenCalledWith('near')

      it 'should call addResultFor category', ->
        expect(@view.addResultFor).toHaveBeenCalledWith('category', 'Transit')

      it 'should call addResultFor search', ->
        expect(@view.addResultFor).toHaveBeenCalledWith('search', 'something')

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

  describe '#addResultFor', ->
    describe 'when type is filter', ->
      it 'should generate the correct html', ->
        expect(@view.addResultFor('filter', 'Recommended').html()).toEqual('Recommended &nbsp; | &nbsp; <a class="remove-filter" data-filter-type="filter">x</a>')

    describe 'when type is tags', ->
      it 'should generate the correct html', ->
        expect(@view.addResultFor('tags', 'Bike', 'bike').html()).toEqual('Bike &nbsp; | &nbsp; <a class="remove-filter" data-filter-type="tags" data-filter-value="bike">x</a>')

  describe '#removeResultFor', ->
    beforeEach ->
      spyOn($.fn, 'parent').andReturn($.fn)
      spyOn($.fn, 'remove')
      spyOn(@view, 'toggleDisplayResultsFor')
      @view.removeResultFor('tags')

    it "should call parent with .filter", ->
      expect($.fn.parent).wasCalledWith('.filter')

    it 'should call remove', ->
      expect($.fn.remove).toHaveBeenCalled()

    it 'should call toggleDisplayResultsFor', ->
      expect(@view.toggleDisplayResultsFor).toHaveBeenCalled()

  describe '#toggleDisplayResultsFor', ->
    beforeEach ->
      spyOn($.fn, 'show')
      spyOn($.fn, 'hide')

    describe 'when has filters', ->
      beforeEach ->
        spyOn($.fn, 'size').andReturn(1)
        @view.toggleDisplayResultsFor()

      it 'should show .results-for', ->
        expect($.fn.show).toHaveBeenCalled()

      it 'should not hide .results-for', ->
        expect($.fn.hide).not.toHaveBeenCalled()

    describe 'when has no filters', ->
      beforeEach ->
        spyOn($.fn, 'size').andReturn(0)
        @view.toggleDisplayResultsFor()

      it 'should not show .results-for', ->
        expect($.fn.show).not.toHaveBeenCalled()

      it 'should hide .results-for', ->
        expect($.fn.hide).toHaveBeenCalled()

  describe '#removeFilter', ->
    beforeEach ->
      @event =
        preventDefault: ->
        currentTarget: $('<a>').attr('data-filter-type', 'filter')

      spyOn($.fn, 'val').andReturn($.fn)
      spyOn($.fn, 'trigger')
      spyOn($.fn, 'click')
      spyOn(@event, 'preventDefault')
      spyOn(@view, 'removeResultFor')
      spyOn(@view, 'process')

    describe 'when type is tags', ->
      beforeEach ->
        @tags_event =
          preventDefault: ->
          currentTarget: $('<a>').attr('data-filter-type', 'tags')

        spyOn(@tags_event, 'preventDefault')
        @view.removeFilter(@tags_event)

      it "should not call removeResultFor function", ->
        expect(@view.removeResultFor).not.wasCalled()

      it 'should call process', ->
        expect(@view.process).toHaveBeenCalled()

      it 'should call click', ->
        expect($.fn.click).toHaveBeenCalled()

      it "should call preventDefault", ->
        expect(@tags_event.preventDefault).wasCalled()

    describe 'when type is search', ->
      beforeEach ->
        @search_event =
          preventDefault: ->
          currentTarget: $('<a>').attr('data-filter-type', 'search')

        spyOn(@search_event, 'preventDefault')
        @view.removeFilter(@search_event)

      it "should call removeResultFor function", ->
        expect(@view.removeResultFor).wasCalled()

      it 'should call process', ->
        expect(@view.process).toHaveBeenCalled()

      it 'should set empty value', ->
        expect($.fn.val).toHaveBeenCalledWith('')

      it "should call preventDefault", ->
        expect(@search_event.preventDefault).wasCalled()

    describe 'when type is other', ->
      beforeEach ->
        @view.removeFilter(@event)

      it "should call removeResultFor function", ->
        expect(@view.removeResultFor).wasCalled()

      it 'should set empty value', ->
        expect($.fn.val).toHaveBeenCalledWith('')

      it 'should trigger the change event', ->
        expect($.fn.trigger).toHaveBeenCalledWith('change', true)

      it "should call preventDefault", ->
        expect(@event.preventDefault).wasCalled()

