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

    @executePHPFunction "getQuestions", "",
      (object) =>
        @_questions = object
        console.log @_questions


  executePHPFunction: (method, values, callBack=null) ->
    # $("#loading_popup").fadeIn()
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
        # $("#loading_popup").fadeOut()
