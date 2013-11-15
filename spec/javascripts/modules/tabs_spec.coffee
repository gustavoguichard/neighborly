describe 'Tabs', ->
  beforeEach ->
    $(document.body).append $('<nav>').addClass('tabs').attr('data-target-container', '.some-container').html($('<a>'))
    @view = new Neighborly.Tabs()

  describe '#initialize', ->
    it 'should set $target_container var', ->
      @view.initialize()
      expect(@view.$target_container).toEqual('.some-container')

    it 'should init pjax by default', ->
      spyOn(@view, 'initPjax')
      @view.initialize()
      expect(@view.initPjax).toHaveBeenCalled()

    it 'should not init pjax when pass the param', ->
      spyOn(@view, 'initPjax')
      @view.initialize({ enable_pjax: false })
      expect(@view.initPjax).not.toHaveBeenCalled()

  describe '#initPjax', ->
    beforeEach ->
      @spy = spyOn($.fn, 'pjax')
      spyOn(@view, 'bindPjaxLoading')
      @view.initPjax()

    it 'should init pjax with correct container', ->
      expect(@spy).toHaveBeenCalledWith('a', '.some-container')

    it 'should call bindPjaxLoading', ->
      expect(@view.bindPjaxLoading).toHaveBeenCalled()


  describe '#toggleSelected', ->
    beforeEach ->
      event =
        currentTarget: 'a'

      spyOn($.fn, 'find').andReturn($.fn)
      spyOn($.fn, 'addClass')
      spyOn($.fn, 'removeClass')
      @view.toggleSelected(event)

    it 'should find for selected class', ->
      expect($.fn.find).toHaveBeenCalledWith('.selected')

    it 'should remove existing selected class', ->
      expect($.fn.removeClass).toHaveBeenCalledWith('selected')

    it 'should add selected class to current target', ->
      expect($.fn.addClass).toHaveBeenCalledWith('selected')

  describe 'bindPjaxLoading', ->
    beforeEach ->
      spyOn($.fn, 'on')
      @view.bindPjaxLoading()

    it 'should bind pjax:send', ->
     expect($.fn.on).toHaveBeenCalledWith('pjax:send', jasmine.any(Function))

    it 'should bind pjax:complete', ->
     expect($.fn.on).toHaveBeenCalledWith('pjax:complete', jasmine.any(Function))
