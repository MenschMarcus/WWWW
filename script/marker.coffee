window.WWWW ?= {}

#   -----------------------------------------------------------------
class WWWW.Marker
  constructor: (parentDiv) ->
    @_parentDiv = parentDiv
    @_markerDiv = document.createElement("div")   
    @_markerDiv.className = "marker"
    @_parentDiv.appendChild @_markerDiv

    $(@_markerDiv).draggable()

  setPosition: (x, y) ->
    #@_markerDiv.style.left = x + "px"
    #@_markerDiv.style.top = y + "px"
    console.log "try to set position"
