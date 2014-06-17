window.WWWW ?= {}

getRandomInt= (min, max) ->
  return Math.floor(Math.random() * (max - min + 1)) + min

#   -----------------------------------------------------------------
class WWWW.QuestionHandler
  constructor: () ->
    @_questions = null
    @_askedQuestions = []
    @_questionCount = 0
    @_mapDiv = document.getElementById("map")
    @_timeline = document.getElementById("timeline")
    @_bar = $('#progress-bar')

    @_time_per_question = 20 #in seconds

    @_question_answered = false

    @_map_marker = new WWWW.Marker(@_mapDiv)
    @_map_marker.setPosition 50, 50

    @_map_result_marker = new WWWW.Marker @_mapDiv, null, true
    @_map_result_marker.setPosition 150, 150
    @_map_result_marker.hide()
    @_map_result_marker.lock()

    @_tl_marker = new WWWW.Marker(@_timeline, "x")
    @_tl_marker.setPosition 10, 0

    @_tl_result_marker = new WWWW.Marker @_timeline, "x", true
    @_tl_result_marker.setPosition 200, 0
    @_tl_result_marker.hide()
    @_tl_result_marker.lock()

    @_executePHPFunction "getQuestions", "", (json_string) =>
      @_questions = JSON.parse(json_string)
      @_questionCount = @_questions?.length
      @postNewQuestion()

    # submit answer on click
    $('#submit-answer').on 'click', () =>
      @questionAnswered()

    # post new question on click
    $('#next-question').on 'click', () =>
      @postNewQuestion()

  questionAnswered: =>
    unless @_question_answered
      @_bar.removeClass 'progress-bar-animate progress-bar'
      @_bar.css "width", "0"

      @_question_answered = true
      @showResults()

  showResults: =>
    @_map_result_marker.show()
    @_map_marker.lock()

    @_tl_result_marker.show()
    @_tl_marker.lock()

    $('#result-display').modal('show');

  postNewQuestion: =>
    if @_questions?
      if @_askedQuestions.length is @_questionCount
        $('#question').html "Du hast alle Fragen beantwortet!"
      else
        @_question_answered = false
        @_bar.addClass 'progress-bar-animate progress-bar'
        @_bar.css "width", "100%"
        new_question = getRandomInt 0, (@_questionCount - 1)
        while @_askedQuestions.indexOf(new_question) isnt -1
          new_question = getRandomInt 0, (@_questionCount - 1)

        @_askedQuestions.push new_question
        $('#question').html @_questions[new_question].text

        $('#result-display').modal('hide');

        @_map_result_marker.hide()
        @_map_marker.release()

        @_tl_result_marker.hide()
        @_tl_marker.release()

        # submit answer when time is up
        window.setTimeout () =>
           @questionAnswered()
        , @_time_per_question * 1000





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
