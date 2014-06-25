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
    @_session_id = null

    $('#results').hide({duration: 0})
    @_answerPrecisionThreshold = 0.9 # time and space need to be 99% correct to achieve the maximum score
    @_answerChanceLevel = 0.6 # time and space need to be at least 50% correct to score any point

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

    @_browserDetector = new WWWW.BrowserDetector()

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

    WWWW.executePHPFunction "getSessionID", "", (s_id) =>
      @_currentAnswer.session_id = s_id
      @_session_id = s_id

      WWWW.executePHPFunction "getMaps", "", (map_string) =>
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

        WWWW.executePHPFunction "getTimelines", "", (tl_string) =>
          @_timelines = new Object()
          tls = JSON.parse tl_string

          for tl in tls
            tl.min_year = parseInt(tl.min_year)
            tl.max_year = parseInt(tl.max_year)
            @_timelines[tl.id] = tl

          send =
            session_id: "#{@_session_id}"
          WWWW.executePHPFunction "userIsFunny", send, (response) =>
            rep = JSON.parse(response)
            send = {}
            if !rep? or rep.length == 0
              send =
                funny: Math.round(Math.random())
              @_currentAnswer.funny = send.funny
              add_user_send =
                table: "user"
                values: "'#{@_session_id}', #{send.funny}"
                names: "`session_id`, `funny`"
              WWWW.executePHPFunction "insertIntoDB", add_user_send, null
            else
              send =
                funny: parseInt(rep[0].funny)
              @_currentAnswer.funny = send.funny

            WWWW.executePHPFunction "getQuestions", send, (question_string) =>
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
      unless @_mapMarker.isLocked()
        offset = $(@_mapDiv).offset()
        newPos =
          x : event.clientX - offset.left
          y : event.clientY - offset.top

        @_mapMarker.setPosition newPos

    # place timeline marker on click
    $(@_timelineDiv).on 'click', (event) =>
      unless @_tlMarker.isLocked()
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
    $("#answer-spatial-distance").html spatialDistance + " km"
    $("#answer-temporal-distance").html temporalDistance + if temporalDistance is 1 then " Jahr" else " Jahre"
    $("#answer-info").html @_currentQuestion.answer

    spatialSpread = @_getMeterDistance @_currentMap.minLatLng, @_currentMap.maxLatLng
    spatialScore = 1 - spatialDistance/spatialSpread

    spatialScore = if spatialScore >= @_answerChanceLevel then (spatialScore - @_answerChanceLevel) / (1-@_answerChanceLevel) else 0
    spatialScore = (Math.min(1.0, (spatialScore + 1.0 - @_answerPrecisionThreshold)) - 1.0 + @_answerPrecisionThreshold ) / @_answerPrecisionThreshold


    timeScore = 1 - temporalDistance / (@_currentTimeline.max_year - @_currentTimeline.min_year)

    timeScore = if timeScore >= @_answerChanceLevel then (timeScore - @_answerChanceLevel)/ (1-@_answerChanceLevel) else 0
    timeScore = (Math.min(1.0, (timeScore + 1.0 - @_answerPrecisionThreshold)) - 1.0 + @_answerPrecisionThreshold ) / @_answerPrecisionThreshold


    score = Math.round( (Math.pow(spatialScore, 3) + Math.pow(timeScore, 3)) / 2 * @_maxScore)

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

    $("#submit-answer").addClass("disabled");

    unless WWWW.DRY_RUN
      @submitAnswer()

    window.setTimeout () =>
      $("#next-question").removeClass("invisible");
      $("#submit-answer").addClass("invisible");
      @_countDownDiv.text('');
      $("#results").animate({height: "show", opacity: "show"});
    , 2000

  postNewQuestion: =>
    if @_questions?
      if @_questionCount is (@_questionsPerRound + 1)
        @roundEnd()
      else
        @_questionAnswered = false

        # reset loading bar
        @_barDiv.addClass 'animate'
        @_barDiv.css "width", "0%"

        @_mapMarker.unfade()
        @_tlMarker.unfade()

        $("#results").animate({height: "hide", opacity: "hide"});

        $("#next-question").addClass("invisible");
        $("#submit-answer").removeClass("invisible");
        $("#submit-answer").removeClass("disabled");

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

    if @_askedQuestions.length is @_totalQuestionCount
      @_askedQuestions = []

  submitAnswer: =>
    a = @_currentAnswer
    send =
      table: "answer"
      values: "#{a.q_id}, #{a.round_count}, '#{a.session_id}',
               #{a.lat}, #{a.long}, #{a.year}, #{a.score}, #{a.start_time},
               #{a.end_time}, #{a.funny}, '#{@_browserDetector.platform}',
               '#{@_browserDetector.browser}', '#{@_browserDetector.version}'"
      names: "`q_id`, `round_count`, `session_id`,
              `lat`, `long`, `year`, `score`, `start_time`,
              `end_time`, `funny`, `platform`,
              `browser`, `version`"

    WWWW.executePHPFunction "insertIntoDB", send, (response) =>
      console.log "Answer was submitted with response #{response}"

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
