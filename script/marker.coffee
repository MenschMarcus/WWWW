window.WWWW ?= {}

#   -----------------------------------------------------------------
class WWWW.Marker
  constructor: (parentDiv, axis=null, is_flipped=false, is_result=false) ->
    @_parentDiv = parentDiv
    @_axis = axis
    @_is_flipped = is_flipped
    @_markerDiv = document.createElement("div")
    @_markerDiv.className = if is_result then "marker marker-result" else "marker marker-answer"
    if @_is_flipped
      @_markerDiv.className += " marker-flipped"
    @_parentDiv.appendChild @_markerDiv

    if @_axis?
      $(@_markerDiv).draggable(containment: "parent", axis: @_axis)
    else
      $(@_markerDiv).draggable(containment: "parent")

    $(@_markerDiv).hide( { duration: 0 } );

  getDiv: ->
    @_markerDiv

  getPosition: ->
    pos =
      x : $(@_markerDiv).offset().left + $(@_markerDiv).width() / 2
      y : $(@_markerDiv).offset().top + if @_is_flipped then 0 else $(@_markerDiv).height()

  setPosition: (pos) ->
    @_markerDiv.style.left = pos.x - $(@_markerDiv).width() / 2 + "px"
    @_markerDiv.style.top = pos.y  - (if @_is_flipped then 0 else $(@_markerDiv).height()) + "px"

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

  release: () ->
    $(@_markerDiv).draggable "enable"
