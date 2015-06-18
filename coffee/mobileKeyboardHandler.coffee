window.WWWW ?= {}

#   -----------------------------------------------------------------
class WWWW.MobileKeyboardHandler

    constructor: () ->
      @_initialWindowHeight = window.innerHeight;

      $("body").css "height", "#{@_initialWindowHeight}px"
      $(".phone-inner").css "height", "#{$('.phone-inner').height()}px"
      $("#map").css "height", "#{$('.phone-inner').height()}px"
