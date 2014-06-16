window.WWWW ?= {}

#   -----------------------------------------------------------------
class WWWW.Marker
  constructor: (parentDiv, xPos, yPos) ->
    @_xPos = xPos
    @_yPos = yPos
    @_parentDiv = parentDiv
    @_markerDiv = document.createElement("div")
    @_markerDiv.className = "marker"
    @_parentDiv.appendChild @_markerDiv
