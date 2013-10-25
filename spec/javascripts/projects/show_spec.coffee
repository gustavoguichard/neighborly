describe "Projects.Show", ->
  beforeEach ->
    $(document.body).append $('<div>').addClass('project-page').html($('<div>').addClass('status-bar'))
    @view = new Neighborly.Projects.Show.init()

  describe "#initialize", ->
    it 'should call statusBar method', ->
      spyOn(@view, 'statusBar')
      @view.initialize()
      expect(@view.statusBar).toHaveBeenCalled()

  describe '#statusBar', ->
    it 'should get the offset', ->
      spyOn($.fn, 'offset').andReturn({top: 5})
      @view.statusBar()
      expect($.fn.offset).toHaveBeenCalled()

    it 'should set a function to scroll', ->
      spyOn($.fn, 'scroll')
      @view.statusBar()
      expect($.fn.scroll).toHaveBeenCalledWith(jasmine.any(Function))

    it 'should add fixed class to status bar when scoll top is more then status bar offset', ->
      spyOn($.fn, 'scrollTop').andReturn(10)
      spyOn($.fn, 'offset').andReturn({top: 5})
      @view.statusBar()
      $(document).trigger('scroll')
      expect($('.status-bar').hasClass('fixed')).toBeTruthy()

    it 'should not add fixed class to status bar when scoll top is less then status bar offset', ->
      spyOn($.fn, 'scrollTop').andReturn(10)
      spyOn($.fn, 'offset').andReturn({top: 15})
      @view.statusBar()
      $(document).trigger('scroll')
      expect($('.status-bar').hasClass('fixed')).toBeFalsy()

