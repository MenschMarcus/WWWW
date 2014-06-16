window.WWWW ?= {}

#   -----------------------------------------------------------------
class WWWW.Question
  constructor: (id, text, map_img, tl_img, map_x, map_y, tl_x) ->
    @id = id
    @text = text
    @map_img = map_img
    @tl_img = tl_img
    @map_x = map_x
    @map_y = map_y
    @tl_x = tl_x

#   -----------------------------------------------------------------
class WWWW.QuestionHandler
  constructor: () ->
    @_questions = null
    @_mapDiv = document.getElementById("map")
    
    marker = new WWWW.Marker(@_mapDiv)
    marker.setPosition 50, 50

    @executePHPFunction "getQuestions", "", (json_string) =>
      @_questions = JSON.parse(json_string)
      for question, i in @_questions
        console.log "Frage " + (i + 1) + ": " + question.text

  executePHPFunction: (method, values, callBack=null) ->
    if (window.XMLHttpRequest)
      xmlhttp = new XMLHttpRequest()
    else
      xmlhttp = new ActiveXObject("Microsoft.XMLHTTP")
    xmlhttp.open( "POST", "./php/execute.php?" + method + "=true", true );
    xmlhttp.setRequestHeader( "Content-Type", "application/json" );
    xmlhttp.send( JSON.stringify(values) );
    xmlhttp.onreadystatechange= =>
      if (xmlhttp.readyState==4 && xmlhttp.status==200)
        callBack? xmlhttp.responseText
