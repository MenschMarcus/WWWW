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

getRandomInt= (min, max) ->
  return Math.floor(Math.random() * (max - min + 1)) + min


#   -----------------------------------------------------------------
class WWWW.QuestionHandler
  constructor: () ->
    @_questions = null
    @_askedQuestions = []
    @_questionCount = 0
    @_mapDiv = document.getElementById("map")
    
    marker = new WWWW.Marker(@_mapDiv)
    marker.setPosition 50, 50

    @_executePHPFunction "getQuestions", "", (json_string) =>
      @_questions = JSON.parse(json_string)
      @_questionCount = @_questions?.length
      @_postNewQuestion()

  _postNewQuestion: =>
    if @_questions?
      if @_askedQuestions.length is @_questionCount
        console.log "All questions asked!"
      else
        new_question = 0
        while @_askedQuestions.indexOf(new_question) isnt -1
          console.log new_question
          new_question = getRandomInt 0, (@_questionCount - 1)

        @_askedQuestions.push new_question
        console.log @_questions[new_question].text
        $('#question').html @_questions[new_question].text


  _executePHPFunction: (method, values, callBack=null) ->
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
