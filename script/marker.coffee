window.WWWW ?= {}

#   -----------------------------------------------------------------
class WWWW.Marker
  constructor: (parentDiv, classString="", axis=null, isFlipped=false) ->
    @_parentDiv = parentDiv
    @_axis = axis
    @_isFlipped = isFlipped
    @_isLocked = false
    @_markerDiv = document.createElement("div")
    @_markerDiv.className = classString
    @_parentDiv.appendChild @_markerDiv

    $(@_markerDiv).draggable
      containment: "parent"
      axis: @_axis
      drag: (event, ui) =>


    $(@_markerDiv).hide( { duration: 0 } );

  getDiv: ->
    @_markerDiv

  getPosition: ->
    pos =
      x : $(@_markerDiv).position().left + $(@_markerDiv).width() / 2
      y : $(@_markerDiv).position().top + if @_isFlipped then 0 else $(@_markerDiv).height()

  setPosition: (pos) ->
    $(@_markerDiv).css
      left: pos.x - $(@_markerDiv).width() / 2 + 2 + "px"
      top: pos.y  - (if @_isFlipped then 0 else $(@_markerDiv).height()) + "px"

  hide: () ->
    $(@_markerDiv).hide( "drop", { direction: "up" } );

  show: () ->
    $(@_markerDiv).show( "bounce", { times: 2, distance: 100 }, "slow" );

  fade: () ->
    $(@_markerDiv).addClass "fade"

  unfade: () ->
    $(@_markerDiv).removeClass "fade"

  lock: () ->
    $(@_markerDiv).draggable "disable"
    @_isLocked = true

  release: () ->
    $(@_markerDiv).draggable "enable"
    @_isLocked = false

  isLocked: () ->
    @_isLocked
