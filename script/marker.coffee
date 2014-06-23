window.WWWW ?= {}

#   -----------------------------------------------------------------
class WWWW.Marker
  constructor: (parentDiv, classString="", axis=null, isFlipped=false) ->
    @_parentDiv = parentDiv
    @_axis = axis
    @_isFlipped = isFlipped
    @_markerDiv = document.createElement("div")
    @_markerDiv.className = classString
    @_parentDiv.appendChild @_markerDiv

    $(@_markerDiv).draggable
      containment: "parent"
      axis: @_axis
      drag: (event, ui) =>


  getDiv: ->
    @_markerDiv

  getPosition: ->
    pos =
      x : $(@_markerDiv).offset().left + $(@_markerDiv).width() / 2
      y : $(@_markerDiv).offset().top + if @_isFlipped then 0 else $(@_markerDiv).height()

  setPosition: (pos) ->
    @_markerDiv.style.left = pos.x - $(@_markerDiv).width() / 2 + "px"
    @_markerDiv.style.top = pos.y  - (if @_isFlipped then 0 else $(@_markerDiv).height()) + "px"

  hide: () ->
    $(@_markerDiv).css "visibility", "hidden"

  show: () ->
    $(@_markerDiv).css "visibility", "visible"

  fade: () ->
    $(@_markerDiv).addClass "fade"

  unfade: () ->
    $(@_markerDiv).removeClass "fade"

  lock: () ->
    $(@_markerDiv).draggable "disable"

  release: () ->
    $(@_markerDiv).draggable "enable"
