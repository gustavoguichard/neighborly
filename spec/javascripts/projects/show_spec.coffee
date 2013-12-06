describe "Projects.Show", ->
  beforeEach ->

  describe "#initialize", ->



describe "Projects.Show.StatusBar", ->
  beforeEach ->
    $(document.body).append $('<div>').addClass('project-page').html($('<div>').addClass('status-bar'))
    @view = new Neighborly.Projects.Show.StatusBar()

  describe '#initialize', ->
    it 'should get the offset', ->
      spyOn($.fn, 'offset').andReturn({top: 5})
      @view.initialize()
      expect($.fn.offset).toHaveBeenCalled()

    it 'should set a function to scroll', ->
      spyOn($.fn, 'scroll')
      @view.initialize()
      expect($.fn.scroll).toHaveBeenCalledWith(jasmine.any(Function))

    it 'should add show class to status bar when scoll top is more then status bar offset', ->
      spyOn($.fn, 'scrollTop').andReturn(10)
      spyOn($.fn, 'offset').andReturn({top: 5})
      @view.initialize()
      $(document).trigger('scroll')
      expect($('.status-bar').hasClass('show')).toBeTruthy()

    it 'should not add show class to status bar when scoll top is less then status bar offset', ->
      spyOn($.fn, 'scrollTop').andReturn(10)
      spyOn($.fn, 'offset').andReturn({top: 15})
      @view.initialize()
      $(document).trigger('scroll')
      expect($('.status-bar').hasClass('show')).toBeFalsy()

