window.WWWW ?= {}

WWWW.DRY_RUN = true

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
    @funny = 0

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

    $('#results').hide({duration: 0})
    @_answerPrecisionThreshold = 0.99 # time and space need to be 99% correct to achieve the maximum score

    @_mapDiv = document.getElementById("map")
    @_timelineDiv = document.getElementById("timeline")
    @_barDiv = $('#question-progress')
    @_countDownDiv = $('#count-down')

    @_timePerQuestion = 30 #in seconds
    @_remainingTime = 0 #in seconds

    @_questionAnswered = false
    @_questionTimeout = null
    @_countDownTimeout = null

    @_currentAnswer = new WWWW.Answer()

    @_maps = null
    @_currentMap = null

    @_mapMarker = new WWWW.Marker @_mapDiv, "marker marker-map marker-map-answer"
    startPos =
      x : $(@_mapDiv).width()/2
      y : $(@_mapDiv).height()/2
    @_mapMarker.setPosition startPos
    @_mapMarker.show()

    @_mapResultMarker = new WWWW.Marker @_mapDiv, "marker marker-map marker-map-result"
    @_mapResultMarker.lock()


    @_timelines = null
    @_currentTimeline = null

    @_tlMarker = new WWWW.Marker @_timelineDiv, "marker marker-time marker-time-answer", "x", true
    startPos =
      x : $(@_timelineDiv).width()/2
      y : $(@_timelineDiv).height() - 20
    @_tlMarker.setPosition startPos
    @_tlMarker.show()

    yearDiv = document.createElement "div"
    yearDiv.id = "yearDiv"
    yearDiv.className = "yearDiv"
    @_tlMarker.getDiv().appendChild yearDiv

    $(@_tlMarker.getDiv()).on "drag", (event, ui)=>
      $(yearDiv).html @_pixelToTime @_tlMarker.getPosition()

    @_tlResultMarker = new WWWW.Marker @_timelineDiv, "marker marker-time marker-time-result", "x", true
    @_tlResultMarker.lock()

    yearResultDiv = document.createElement "div"
    yearResultDiv.id = "yearResultDiv"
    yearResultDiv.className = "yearDiv"
    @_tlResultMarker.getDiv().appendChild yearResultDiv

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

        send =
          funny: Math.round(Math.random())
        @_currentAnswer.funny = send.funny

        @_executePHPFunction "getQuestions", send, (question_string) =>
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
        y : $(@_timelineDiv).height() - 20

      @_tlMarker.setPosition newPos
      $("#yearDiv").html @_pixelToTime @_tlMarker.getPosition()

  questionAnswered: =>
    unless @_questionAnswered
      @_barDiv.removeClass 'animate'
      @_barDiv.css "width", "100%"

      window.clearTimeout @_questionTimeout
      window.clearTimeout @_countDownTimeout

      @_questionAnswered = true
      @_currentAnswer.end_time = (new Date()).getTime()
      @showResults()

  showResults: =>
    mapResultPos = @_latLngToPixel @_currentQuestion.latLng

    @_mapResultMarker.setPosition mapResultPos
    @_mapResultMarker.show()
    @_mapMarker.lock()

    tlResultPos = @_timeToPixel(@_currentQuestion.year)
    tlResultPos.y = $(@_timelineDiv).height() - 20
    @_tlResultMarker.setPosition tlResultPos
    @_tlResultMarker.show()
    $("#yearResultDiv").html @_pixelToTime tlResultPos

    @_tlMarker.lock()

    answerLatLng = @_pixelToLatLng @_mapMarker.getPosition()
    spatialDistance = @_getMeterDistance answerLatLng, @_currentQuestion.latLng

    @_mapMarker.fade()
    @_tlMarker.fade()

    answerTime = @_pixelToTime @_tlMarker.getPosition()
    temporalDistance = Math.abs(answerTime - @_currentQuestion.year)

    $("#answer-location").html @_currentQuestion.location
    $("#answer-year").html @_currentQuestion.year
    $("#answer-spatial-distance").html spatialDistance
    $("#answer-temporal-distance").html temporalDistance
    $("#answer-info").html @_currentQuestion.answer

    latDist = Math.abs (answerLatLng.lat - @_currentQuestion.latLng.lat)
    latSpread = Math.abs (@_currentMap.lat_max - @_currentMap.lat_min)
    latScore = 1 - latDist / latSpread

    latScore = if latScore >= @_answerPrecisionThreshold then 1 else latScore

    lngDist = Math.abs (answerLatLng.lat - @_currentQuestion.latLng.lat)
    lngSpread = Math.abs (@_currentMap.long_max - @_currentMap.long_min)
    lngScore = 1 - lngDist / lngSpread

    lngScore = if lngScore >= @_answerPrecisionThreshold then 1 else lngScore

    timeScore = 1 - (temporalDistance) / (@_currentTimeline.max_year - @_currentTimeline.min_year)

    timeScore = if timeScore >= @_answerPrecisionThreshold then 1 else timeScore

    score = Math.round( Math.pow(latScore, 2) * Math.pow(lngScore, 2) * Math.pow(timeScore, 2) * @_maxScore)

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

    unless WWWW.DRY_RUN
      @submitAnswer()

    window.setTimeout () =>
      $("#next-question").removeClass("invisible");
      $("#submit-answer").addClass("invisible");
      @_countDownDiv.text('');
      $('#results').show(400)
    , 2000

  postNewQuestion: =>
    if @_questions?
      if (@_questionCount is @_questionsPerRound + 1) or (
        @_askedQuestions.length is @_totalQuestionCount)
        @roundEnd()
      else
        @_questionAnswered = false

        # reset loading bar
        @_barDiv.addClass 'animate'
        @_barDiv.css "width", "0%"

        @_mapMarker.unfade()
        @_tlMarker.unfade()

        $('#results').hide(400)

        $("#next-question").addClass("invisible");
        $("#submit-answer").removeClass("invisible");

        @_remainingTime = @_timePerQuestion

        updateCountDown = () =>
          if @_remainingTime--
            @_countDownDiv.text(@_remainingTime + ' Sekunden verbleibend');
            @_countDownTimeout =  window.setTimeout updateCountDown, 1000

        @_countDownTimeout = window.setTimeout updateCountDown, 0

        # search for new question
        newQuestionId = getRandomInt 0, (@_totalQuestionCount - 1)
        while @_askedQuestions.indexOf(newQuestionId) isnt -1
          newQuestionId = getRandomInt 0, (@_totalQuestionCount - 1)


        # update question
        @_askedQuestions.push newQuestionId
        @_currentQuestion = @_questions[newQuestionId]
        @_currentMap = @_maps[@_currentQuestion.map_id]
        @_currentTimeline = @_timelines[@_currentQuestion.tl_id]


        $("#yearDiv").html @_pixelToTime @_tlMarker.getPosition()
        $('#question').html @_currentQuestion.text
        $('#question-number').html @_questionCount
        $('#questions-per-round').html @_questionsPerRound
        $('#map').css "background-image", "url('img/#{@_currentMap.file_name}')"
        $('#timeline').css "background-image", "url('img/#{@_currentTimeline.file_name}')"


        # hide old result and update result markers
        $('#result-display').modal('hide');
        $('#round-end-display').modal('hide');


        @_mapResultMarker.hide()
        @_mapMarker.release()

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
      console.log a
      send =
        table: "answer"
        values: "#{a.q_id}, #{a.round_count}, '#{a.session_id}', #{a.lat}, #{a.long}, #{a.year}, #{a.score}, #{a.start_time}, #{a.end_time}, #{a.funny}"
        names: "`q_id`, `round_count`, `session_id`, `lat`, `long`, `year`, `score`, `start_time`, `end_time`, `funny`"

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

    lngDiff = @_currentMap.maxLatLng.lng - @_currentMap.minLatLng.lng
    globalRadius = $("#map").width() / lngDiff * 360/(2 * Math.PI)

    mapLatBottomRadian = @_degToRad @_currentMap.maxLatLng.lat
    offsetY = globalRadius / 2 * Math.log( (1 + Math.sin(mapLatBottomRadian) ) / (1 - Math.sin(mapLatBottomRadian))  )
    equatorY = $("#map").height() + offsetY
    a = (equatorY - pos.y )/ globalRadius

    latLng =
      lat : 180/Math.PI * (2 * Math.atan(Math.exp(a)) - Math.PI/2);
      lng :  @_currentMap.minLatLng.lng + pos.x / $("#map").width() * lngDiff;

    latLng

  _latLngToPixel: (latLng) =>

    getMerc = (lat) =>
      Math.log(Math.tan((Math.PI/4)+(lat*Math.PI/360)));

    merc = getMerc(latLng.lat)
    minMerc = getMerc(@_currentMap.minLatLng.lat)
    maxMerc = getMerc(@_currentMap.maxLatLng.lat)

    y_pos = (merc - minMerc) / (maxMerc - minMerc)
    x_pos = (latLng.lng - @_currentMap.minLatLng.lng) / (@_currentMap.maxLatLng.lng - @_currentMap.minLatLng.lng)

    pos =
      x : x_pos * $("#map").width()
      y : y_pos * $("#map").height()

    pos

  _getMeterDistance: (latLng1, latLng2) =>
    earthRadius = 6371 # in km

    deltaLat = @_degToRad(latLng2.lat - latLng1.lat)
    deltaLng = @_degToRad(latLng2.lng - latLng1.lng)


    a = Math.sin(deltaLat/2) * Math.sin(deltaLat/2) +
        Math.cos(@_degToRad(latLng1.lat)) * Math.cos(@_degToRad(latLng2.lat)) *
        Math.sin(deltaLng/2) * Math.sin(deltaLng/2)

    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
    dist = earthRadius * c

    Math.round(dist)

  _pixelToTime: (pos) =>
    relX = pos.x / $("#timeline").width()

    timeDiff = @_currentTimeline.max_year - @_currentTimeline.min_year
    time = Math.round(relX * timeDiff + @_currentTimeline.min_year)

    time


  _timeToPixel: (time) =>
    relTime = (time - @_currentTimeline.min_year) / (@_currentTimeline.max_year - @_currentTimeline.min_year)

    pos =
      x : relTime * $("#timeline").width()
      y : 0

    pos

  _degToRad: (degree) ->
    return degree * (Math.PI / 180)

