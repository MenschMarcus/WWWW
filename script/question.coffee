window.WWWW ?= {}

getRandomInt= (min, max) ->
  return Math.floor(Math.random() * (max - min + 1)) + min

#   -----------------------------------------------------------------
class WWWW.QuestionHandler
  constructor: () ->
    @_questions = null
    @_askedQuestions = []
    @_currentQuestion = null
    @_totalQuestionCount = 0
    @_questionsPerRound = 5
    @_roundCount = 1
    @_mapDiv = document.getElementById("map")
    @_timelineDiv = document.getElementById("timeline")
    @_bar = $('#progress-bar')

    @_time_per_question = 20 #in seconds

    @_question_answered = false
    @_question_timeout = null

    @_maps = null
    @_currentMap = null

    @_map_marker = new WWWW.Marker(@_mapDiv)
    startPos =
      x : 50
      y : 50
    @_map_marker.setPosition startPos

    @_map_result_marker = new WWWW.Marker @_mapDiv, null, true
    @_map_result_marker.hide()
    @_map_result_marker.lock()

    @_tl_marker = new WWWW.Marker(@_timelineDiv, "x")
    startPos =
      x : 10
      y : 0
    @_tl_marker.setPosition startPos

    @_tl_result_marker = new WWWW.Marker @_timelineDiv, "x", true
    @_tl_result_marker.hide()
    @_tl_result_marker.lock()

    @_executePHPFunction "getMaps", "", (map_string) =>
      @_maps = new Object()
      maps = JSON.parse map_string

      for map in maps
        map.minLatLng =
          lat : parseInt(map.lat_min)
          lng : parseInt(map.long_min)

        map.maxLatLng =
          lat : parseInt(map.lat_max)
          lng : parseInt(map.long_max)

        @_maps[map.id] = map

      @_executePHPFunction "getQuestions", "", (question_string) =>
        @_questions = JSON.parse question_string
        for question in @_questions
          question.latLng =
            lat : parseInt(question.lat)
            lng : parseInt(question.long)

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

    answerLatLng = @_pixelToLatLng @_map_marker.getPosition()
    spatialDistance = @_getMeterDistance answerLatLng, @_currentQuestion.latLng
    console.log spatialDistance

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
        newQuestionId = getRandomInt 0, (@_totalQuestionCount - 1)
        while @_askedQuestions.indexOf(newQuestionId) isnt -1
          newQuestionId = getRandomInt 0, (@_totalQuestionCount - 1)


        # update question
        @_askedQuestions.push newQuestionId
        @_currentQuestion = @_questions[newQuestionId]
        @_currentMap = @_maps[@_currentQuestion.map_id]


        $('#question').html @_currentQuestion.text
        $('#map').css "background-image", "url('img/#{@_currentMap.file_name}')"


        # hide old result and update result markers
        $('#result-display').modal('hide');

        @_map_result_marker.setPosition @_latLngToPixel(@_currentQuestion.latLng)
        @_map_result_marker.hide()
        @_map_marker.release()

        @_tl_result_marker.hide()
        @_tl_marker.release()

        # submit answer when time is up
        @_question_timeout = window.setTimeout () =>
           # @questionAnswered()
           # @insertAnswer()
           a = 2
        , @_time_per_question * 1000


  roundEnd: =>
    $('#question').html "Du hast alle Fragen beantwortet!"
    @_roundCount++

  insertAnswer: (session_id, start_time, end_time) =>
    # send =
    #   table: "answer"
    #   values: session_id + ", "+ start_time + ", " + end_time
    #   names: "session_id" + ", " + "start_time" + ", " + "end_time"
    # @_executePHPFunction "insertIntoDB", send, (response) =>
    #   console.log "answer was inserted | " + response

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

  _pixelToLatLng: (pos) =>
    width = $("#map").width()
    height = $("#map").height()

    offset = $("#map").offset()

    relX = (pos.x - offset.left) / width
    relY = (pos.y - offset.top) / height

    latDiff = @_currentMap.maxLatLng.lat - @_currentMap.minLatLng.lat
    lngDiff = @_currentMap.maxLatLng.lng - @_currentMap.minLatLng.lng

    latLng =
      lat : relY * latDiff + @_currentMap.minLatLng.lat
      lng : relX * lngDiff + @_currentMap.minLatLng.lng

    latLng

  _latLngToPixel: (latLng) =>
    relLat = (latLng.lat - @_currentMap.minLatLng.lat) / (@_currentMap.maxLatLng.lat - @_currentMap.minLatLng.lat)
    relLng = (latLng.lng - @_currentMap.minLatLng.lng) / (@_currentMap.maxLatLng.lng - @_currentMap.minLatLng.lng)

    pos =
      x : relLng * $("#map").width()
      y : relLat * $("#map").height()

    pos

  _getMeterDistance: (latLng1, latLng2) =>
    earthRadius = 6371 # in km

    deg2rad = (degree) ->
      return degree * (Math.PI / 180)

    deltaLat = deg2rad(latLng2.lat - latLng1.lat)
    deltaLng = deg2rad(latLng2.lng - latLng1.lng)


    a = Math.sin(deltaLat/2) * Math.sin(deltaLat/2) +
        Math.cos(deg2rad(latLng1.lat)) * Math.cos(deg2rad(latLng2.lat)) *
        Math.sin(deltaLng/2) * Math.sin(deltaLng/2)

    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
    dist = earthRadius * c

    return dist
