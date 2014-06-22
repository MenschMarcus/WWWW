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

  getDiv: ->
    @_markerDiv

  getPosition: ->
    pos =
      x : $(@_markerDiv).offset().left + $(@_markerDiv).width() / 2
      y : $(@_markerDiv).offset().top + $(@_markerDiv).height()

  setPosition: (pos) ->
    @_markerDiv.style.left = pos.x - $(@_markerDiv).width() / 2 + "px"
    @_markerDiv.style.top = pos.y + "px"# - $(@_markerDiv).height() + "px"

  hide: () ->
    $(@_markerDiv).css "visibility", "hidden"

  show: () ->
    $(@_markerDiv).css "visibility", "visible"

  lock: () ->
    $(@_markerDiv).draggable "disable"

  release: () ->
    $(@_markerDiv).draggable "enable"
