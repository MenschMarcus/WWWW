window.WWWW ?= {}

getRandomInt= (min, max) ->
  return Math.floor(Math.random() * (max - min + 1)) + min

#   -----------------------------------------------------------------
class WWWW.QuestionHandler
  constructor: () ->
    @_questions = null
    @_maps = null
    @_askedQuestions = []
    @_totalQuestionCount = 0
    @_questionsPerRound = 5
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

    @_executePHPFunction "getMaps", "", (map_string) =>
      @_maps = new Object()
      maps = JSON.parse map_string

      for map in maps
        console.log map
        @_maps[map.id] = map

      @_executePHPFunction "getQuestions", "", (question_string) =>
        @_questions = JSON.parse question_string
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

        # reset loading bar
        @_bar.addClass 'progress-bar-animate progress-bar'
        @_bar.css "width", "100%"

        # search for new question
        new_question = getRandomInt 0, (@_totalQuestionCount - 1)
        while @_askedQuestions.indexOf(new_question) isnt -1
          new_question = getRandomInt 0, (@_totalQuestionCount - 1)

        currentMap = @_maps[@_questions[new_question].map_id]

        # update question
        @_askedQuestions.push new_question
        $('#question').html @_questions[new_question].text
        $('#map').css "background-image", "url('#{currentMap.file_name}')"


        # hide result
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
