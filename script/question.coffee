window.WWWW ?= {}

getRandomInt= (min, max) ->
  return Math.floor(Math.random() * (max - min + 1)) + min

#   -----------------------------------------------------------------
class WWWW.Answer
  constructor: () ->
    @q_id = null
    @round_count = null
    @session_id = null
    @lat = null
    @long = null
    @year = null
    @score = null
    @start_time = null
    @end_time = null

#   -----------------------------------------------------------------
class WWWW.QuestionHandler
  constructor: () ->
    @_questions = null
    @_askedQuestions = []
    @_currentQuestion = null
    @_totalQuestionCount = 0
    @_questionsPerRound = 5
    @_maxScore = 1000
    @_totalScore = 0
    @_roundCount = 1
    @_questionCount = 1

    @_mapDiv = document.getElementById("map")
    @_timelineDiv = document.getElementById("timeline")
    @_barDiv = $('#progress-bar')

    @_timePerQuestion = 20 #in seconds

    @_questionAnswered = false
    @_questionTimeout = null

    @_currentAnswer = new WWWW.Answer()

    @_maps = null
    @_currentMap = null

    @_mapMarker = new WWWW.Marker(@_mapDiv)
    startPos =
      x : 50
      y : 50
    @_mapMarker.setPosition startPos

    @_mapResultMarker = new WWWW.Marker @_mapDiv, null, true
    @_mapResultMarker.hide()
    @_mapResultMarker.lock()


    @_timelines = null
    @_currentTimeline = null

    @_tlMarker = new WWWW.Marker(@_timelineDiv, "x")
    startPos =
      x : 10
      y : $(@_tlMarker.getDiv()).height()
    @_tlMarker.setPosition startPos

    @_tlResultMarker = new WWWW.Marker @_timelineDiv, "x", true
    @_tlResultMarker.hide()
    @_tlResultMarker.lock()

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

      @_executePHPFunction "getTimelines", "", (tl_string) =>
        @_timelines = new Object()
        tls = JSON.parse tl_string

        for tl in tls
          tl.min_year = parseInt(tl.min_year)
          tl.max_year = parseInt(tl.max_year)
          @_timelines[tl.id] = tl

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

    # post new question on click
    $('#next-round').on 'click', () =>
      @postNewQuestion()

    # place map marker on click
    $(@_mapDiv).on 'click', (event) =>
      offset = $(@_mapDiv).offset()
      newPos =
        x : event.clientX - offset.left
        y : event.clientY - offset.top

      @_mapMarker.setPosition newPos

    # place timeline marker on click
    $(@_timelineDiv).on 'click', (event) =>
      offset = $(@_timelineDiv).offset()
      newPos =
        x : event.clientX - offset.left
        y : $(@_tlMarker.getDiv()).height()

      @_tlMarker.setPosition newPos

  questionAnswered: =>
    unless @_questionAnswered
      @_barDiv.removeClass 'progress-bar-animate progress-bar'
      @_barDiv.css "width", "0"

      window.clearTimeout @_questionTimeout

      @_questionAnswered = true
      @_currentAnswer.end_time = (new Date()).getTime()
      @showResults()

  showResults: =>
    @_mapResultMarker.show()
    @_mapMarker.lock()

    @_tlResultMarker.show()
    @_tlMarker.lock()

    answerLatLng = @_pixelToLatLng @_mapMarker.getPosition()
    spatialDistance = @_getMeterDistance answerLatLng, @_currentQuestion.latLng

    answerTime = @_pixelToTime @_tlMarker.getPosition()
    temporalDistance = Math.abs(answerTime - @_currentQuestion.year)

    $("#answer-location").html @_currentQuestion.location
    $("#answer-year").html @_currentQuestion.year
    $("#answer-spatial-distance").html spatialDistance
    $("#answer-temporal-distance").html temporalDistance

    latScore = 1 - Math.abs((answerLatLng.lat - @_currentQuestion.latLng.lat) / (@_currentMap.lat_max - @_currentMap.lat_min))
    lngScore = 1 - Math.abs((answerLatLng.lng - @_currentQuestion.latLng.lng) / (@_currentMap.long_max - @_currentMap.long_min))
    timeScore = 1 - (temporalDistance) / (@_currentTimeline.max_year - @_currentTimeline.min_year)

    score = Math.round((latScore + lngScore)/2 * timeScore * @_maxScore)

    $("#answer-score").html score
    $("#answer-max-score").html @_maxScore

    @_totalScore += score

    @_currentAnswer.score = score
    @_currentAnswer.lat = answerLatLng.lat
    @_currentAnswer.long = answerLatLng.lng
    @_currentAnswer.year = answerTime
    @_currentAnswer.round_count = @_roundCount
    @_currentAnswer.q_id = @_currentQuestion.id

    @_questionCount += 1

    @submitAnswer()

    window.setTimeout () =>
      $('#result-display').modal('show')
    , 2000

  postNewQuestion: =>
    if @_questions?
      if (@_questionCount is @_questionsPerRound + 1) or (
        @_askedQuestions.length is @_totalQuestionCount)
        @roundEnd()
      else
        @_questionAnswered = false

        # reset loading bar
        @_barDiv.addClass 'progress-bar-animate progress-bar'
        @_barDiv.css "width", "100%"

        # search for new question
        newQuestionId = getRandomInt 0, (@_totalQuestionCount - 1)
        while @_askedQuestions.indexOf(newQuestionId) isnt -1
          newQuestionId = getRandomInt 0, (@_totalQuestionCount - 1)


        # update question
        @_askedQuestions.push newQuestionId
        @_currentQuestion = @_questions[newQuestionId]
        @_currentMap = @_maps[@_currentQuestion.map_id]
        @_currentTimeline = @_timelines[@_currentQuestion.tl_id]


        $('#question').html @_currentQuestion.text
        $('#question-number').html @_questionCount
        $('#questions-per-round').html @_questionsPerRound
        $('#map').css "background-image", "url('img/#{@_currentMap.file_name}')"
        $('#timeline').css "background-image", "url('img/#{@_currentTimeline.file_name}')"


        # hide old result and update result markers
        $('#result-display').modal('hide');
        $('#round-end-display').modal('hide');

        mapResultPos = @_latLngToPixel @_currentQuestion.latLng
        mapResultPos.y += $(@_mapResultMarker.getDiv()).height()
        @_mapResultMarker.setPosition mapResultPos
        @_mapResultMarker.hide()
        @_mapMarker.release()

        tlResultPos = @_timeToPixel(@_currentQuestion.year)
        tlResultPos.y = $(@_tlMarker.getDiv()).height()

        @_tlResultMarker.setPosition tlResultPos
        @_tlResultMarker.hide()
        @_tlMarker.release()

        @_currentAnswer.session_id = 0
        @_currentAnswer.start_time = (new Date()).getTime()

        # submit answer when time is up
        @_questionTimeout = window.setTimeout () =>
           @questionAnswered()
        , @_timePerQuestion * 1000


  roundEnd: =>
    $('#result-display').modal('hide')

    $("#total-score").html @_totalScore
    $("#total-max-score").html @_maxScore * @_questionsPerRound

    $('#round-end-display').modal('show')

    @_totalScore = 0
    @_roundCount++
    @_questionCount = 1

  submitAnswer: =>
    @_executePHPFunction "getSessionID", "", (s_id) =>
      @_currentAnswer.session_id = s_id

      a = @_currentAnswer

      send =
        table: "answer"
        values: "#{a.q_id}, #{a.round_count}, #{a.session_id}, #{a.lat}, #{a.long}, #{a.year}, #{a.score}, #{a.start_time}, #{a.end_time}"
        names: "`q_id`, `round_count`, `session_id`, `lat`, `long`, `year`, `score`, `start_time`, `end_time`"

      @_executePHPFunction "insertIntoDB", send, (response) =>
        console.log "Answer was submitted with response #{response}"

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

    degTorad = (degree) ->
      return degree * (Math.PI / 180)

    deltaLat = degTorad(latLng2.lat - latLng1.lat)
    deltaLng = degTorad(latLng2.lng - latLng1.lng)


    a = Math.sin(deltaLat/2) * Math.sin(deltaLat/2) +
        Math.cos(degTorad(latLng1.lat)) * Math.cos(degTorad(latLng2.lat)) *
        Math.sin(deltaLng/2) * Math.sin(deltaLng/2)

    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
    dist = earthRadius * c

    Math.round(dist)

  _pixelToTime: (pos) =>
    width = $("#timeline").width()
    offset = $("#timeline").offset()
    relX = (pos.x - offset.left) / width

    timeDiff = @_currentTimeline.max_year - @_currentTimeline.min_year
    time = Math.round(relX * timeDiff + @_currentTimeline.min_year)

    time


  _timeToPixel: (time) =>
    relTime = (time - @_currentTimeline.min_year) / (@_currentTimeline.max_year - @_currentTimeline.min_year)

    pos =
      x : relTime * $("#timeline").width()
      y : 0

    pos


