window.WWWW ?= {}

#   -----------------------------------------------------------------
class WWWW.Marker
  constructor: (parentDiv, axis=null) ->
    @_parentDiv = parentDiv
    @_axis = axis
    @_markerDiv = document.createElement("div")   
    @_markerDiv.className = "marker"
    @_parentDiv.appendChild @_markerDiv

    if axis?
      $(@_markerDiv).draggable(containment: "parent", axis: @_axis)
    else
      $(@_markerDiv).draggable(containment: "parent")

    @_parentDiv.onclick = (e) =>
      e.pageX 

  setPosition: (x, y) ->
    @_markerDiv.style.left = x + "px"
    @_markerDiv.style.top = y + "px"
