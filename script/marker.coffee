window.WWWW ?= {}

#   -----------------------------------------------------------------
class WWWW.Marker
  constructor: (parentDiv, axis=null, is_result=false) ->
    @_parentDiv = parentDiv
    @_axis = axis
    @_markerDiv = document.createElement("div")
    @_markerDiv.className = if is_result then "marker-result" else "marker"
    @_parentDiv.appendChild @_markerDiv

    if @_axis?
      $(@_markerDiv).draggable(containment: "parent", axis: @_axis)
    else
      $(@_markerDiv).draggable(containment: "parent")

  setPosition: (x, y) ->
    @_markerDiv.style.left = x + "px"
    @_markerDiv.style.top = y + "px"

  hide: () ->
    $(@_markerDiv).css "visibility", "hidden"

  show: () ->
    $(@_markerDiv).css "visibility", "visible"

  lock: () ->
    $(@_markerDiv).draggable "disable"

  release: () ->
    $(@_markerDiv).draggable "enable"
