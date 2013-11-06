describe "Neighborly", ->

  describe ".init", ->
    it 'should initialize foundation scripts', ->
      foundation = spyOn($.fn, 'foundation')
      Neighborly.init()
      expect($.fn.foundation).toHaveBeenCalled()

    it 'should set the scroll to false on pjax', ->
      Neighborly.init()
      expect($.pjax.defaults.scrollTo).toBeFalsy()

    it 'should set the timeout to false on pjax', ->
      Neighborly.init()
      expect($.pjax.defaults.timeout).toBeFalsy()

  describe ".Loading", ->
    beforeEach ->
      $(document.body).append $('<div id="loading"><div id="back-overlay" style="display: none"></div><div id="front-overlay" style="display: none"></div></div>')

    describe ".show", ->
      it 'is initially hidden', ->
        expect($('#loading #back-overlay').is(':visible')).toBe(false)
        expect($('#loading #front-overlay').is(':visible')).toBe(false)

      it "when calls the show method", ->
        Neighborly.Loading.show()
        expect($('#loading #back-overlay').is(':visible')).toBe(true)
        expect($('#loading #front-overlay').is(':visible')).toBe(true)

    describe ".hide", ->
      it "when calls the hide method", ->
        Neighborly.Loading.show()
        Neighborly.Loading.hide()

        expect($('#loading #back-overlay').is(':visible')).toBe(false)
        expect($('#loading #front-overlay').is(':visible')).toBe(false)

