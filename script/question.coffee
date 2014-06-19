window.WWWW ?= {}

getRandomInt= (min, max) ->
  return Math.floor(Math.random() * (max - min + 1)) + min

#   -----------------------------------------------------------------
class WWWW.QuestionHandler
  constructor: () ->
    @_questions = null
    @_askedQuestions = []
    @_totalQuestionCount = 0
    @_questionsPerRound = 1
    @_roundCount = 1
    @_mapDiv = document.getElementById("map")
    @_timeline = document.getElementById("timeline")
    @_bar = $('#progress-bar')

    @_time_per_question = 20 #in seconds

    @_question_answered = false
    @_question_timeout = null

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
      @_totalQuestionCount = @_questions?.length
      if @_questionsPerRound > @_totalQuestionCount
        @_questionsPerRound = @_totalQuestionCount
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

      window.clearTimeout @_question_timeout

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
      if (@_askedQuestions.length is @_questionsPerRound * @_roundCount) or (
        @_askedQuestions.length is @_totalQuestionCount)
        @roundEnd()
      else
        @_question_answered = false
        @_bar.addClass 'progress-bar-animate progress-bar'
        @_bar.css "width", "100%"
        new_question = getRandomInt 0, (@_totalQuestionCount - 1)
        while @_askedQuestions.indexOf(new_question) isnt -1
          new_question = getRandomInt 0, (@_totalQuestionCount - 1)

        @_askedQuestions.push new_question
        $('#question').html @_questions[new_question].text

        $('#result-display').modal('hide');

        @_map_result_marker.hide()
        @_map_marker.release()

        @_tl_result_marker.hide()
        @_tl_marker.release()

        # submit answer when time is up
        @_question_timeout = window.setTimeout () =>
           @questionAnswered()
           @insertAnswer()
        , @_time_per_question * 1000


  roundEnd: =>
    $('#question').html "Du hast alle Fragen beantwortet!"
    @_roundCount++

  insertAnswer: (session_id, start_time, end_time) =>
    send =
      table: "answer"
      values: session_id + ", "+ start_time + ", " + end_time
      names: "session_id" + ", " + "start_time" + ", " + "end_time"
    @_executePHPFunction "insertIntoDB", send, (response) =>
      console.log "answer was inserted | " + response

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
