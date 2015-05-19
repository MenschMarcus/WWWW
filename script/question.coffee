window.WWWW ?= {}

WWWW.DRY_RUN = true
WWWW.TEST_RUN = false
WWWW.TEST_START_ID = 0

getRandomInt = (min, max) ->
  return Math.floor(Math.random() * (max - min + 1)) + min

getRandomFloat = (min, max) ->
  return Math.random() * (max - min) + min

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
    @_currentQuestionRating = null
    @_totalQuestionCount = 0
    @_questionsPerRound = 5
    @_maxScore = 1000
    @_maxTimeBonus = 10 # in percent of the achieved score
    @_totalScore = 0
    @_roundCount = 1
    @_questionCount = 1
    @_session_id = null
    @_minZoom = 0
    @_maxZoom = 4
    @_startZoom = 3

    # @_highscoreHandler = new WWWW.HighscoreHandler()

    $('#results').hide({duration: 0})
    @_answerPrecisionThreshold = 0.9 # time and space need to be 95% correct to achieve the maximum score
    @_answerChanceLevel = 0.8 # time and space need to be at least 75% correct to score any point
    @_timeBonusThreshold = 5 # time in seconds that may pass before time bonus is reduced

    @_mapDiv = document.getElementById("map")
    @_map = L.map 'map',
      minZoom: @_minZoom
      maxZoom: @_maxZoom
      zoomControl: false
      dragging: true
      touchZoom: true
      scrollWheelZoom: true
      doubleClickZoom: true
      boxZoom: false
      keyboard: false

    @_dontUpdateZoomHandle = false
    @_map.on "zoomend", () =>
      unless @_dontUpdateZoomHandle
        @_updateZoomHandle @_map.getZoom()
      @_dontUpdateZoomHandle = false


    @_map.setView([51.505, -0.09], @_startZoom)
    # tiles = L.tileLayer "tiles/{z}/{x}/{y}.png"
    tiles = L.tileLayer "img/tiles/{z}/{x}/{y}.png"
    tiles.addTo @_map
    @_map.attributionControl.setPrefix ''

    icon = L.icon
      iconUrl: 'img/marker_map.png',
      iconRetinaUrl: 'img/marker_map.png',
      iconSize: [80, 100],
      iconAnchor: [40, 94],
      shadowUrl: 'img/shadow.png',
      shadowRetinaUrl: 'img/shadow.png',
      shadowSize: [54, 29],
      shadowAnchor: [27, 20]


    @_mapMarker = L.marker(new L.LatLng(47.9, 10), {
      draggable: true
      icon: icon
    })
    @_mapMarker.addTo @_map

    $("#map-zoom-handle-outer").draggable
      addClasses: false
      axis: "y"
      containment: "parent"
      drag: (event)=>
        height = $("#map-zoom-slider").height() - $("#map-zoom-handle-outer").height()
        offset = $("#map-zoom-handle-outer").offset().top - $("#map-zoom-slider").offset().top

        $("#map-zoom-handle-outer").removeClass "animate"
        relativeOffset = 1.0 - offset / height
        currentZoom = Math.floor relativeOffset * (@_maxZoom - @_minZoom)
        @_dontUpdateZoomHandle = true
        @_map.setZoom currentZoom

    @_updateZoomHandle @_startZoom

    $("#map-zoom-plus").click () =>
      @_map.zoomIn()
      @_updateZoomHandle Math.min(@_map.getZoom() + 1, @_maxZoom)

    $("#map-zoom-minus").click () =>
      @_map.zoomOut()
      @_updateZoomHandle Math.max(@_map.getZoom() - 1, @_minZoom)

    @_timelineDiv = document.getElementById("timeline")
    @_barDiv = $('#question-progress')

    @_timePerQuestion = 3000 #in seconds

    @_questionAnswered = false
    @_questionTimeout = null

    @_currentAnswer = new WWWW.Answer()

    @_maps = null
    @_currentMap = null

    @_browserDetector = new WWWW.BrowserDetector()

    # @_mapMarker = new WWWW.Marker @_mapDiv, "marker marker-map marker-map-answer"


    @_mapResultMarker = new WWWW.Marker @_mapDiv, "marker marker-map marker-map-result"
    @_mapResultMarker.lock()


    @_timelines = null
    @_currentTimeline = null

    @_tlMarker = new WWWW.Marker @_timelineDiv, "marker marker-time marker-time-answer", "x", true

    @_resetMarkers()
    @_tlMarker.show()
    # @_mapMarker.show()

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
          #@_timelines = new Object()
          @_timelines = []
          tls = JSON.parse tl_string

          for tl in tls
            tl.min_year = parseInt(tl.min_year)
            tl.max_year = parseInt(tl.max_year)
            @_timelines.push tl

          WWWW.executePHPFunction "getQuestions", null, (question_string) =>
            @_questions = JSON.parse question_string
            for question, i in @_questions
              question.latLng =
                lat : parseFloat(question.lat)
                lng : parseFloat(question.long)

            @_totalQuestionCount = @_questions?.length
            if @_questionsPerRound > @_totalQuestionCount
              @_questionsPerRound = @_totalQuestionCount
            @postNewQuestion()

    # submit answer on click
    $('#submit-answer').on 'click', () =>
      @questionAnswered()

    # post new question on click
    $('#next-question').on 'click', () =>
      @submitRating()
      @postNewQuestion()

    # post new question on click
    $('#next-round').on 'click', () =>
      @postNewQuestion()

    # end round on click
    $('#round-end').on 'click', () =>
      @submitRating()
      @roundEnd()

    $("#rate-question").raty
      starType: "i"
      hints: ["","","","",""]
      #path : 'script/third-party/raty/images/'
      click: (rating, event) =>
        @_currentQuestionRating = rating

    # place map marker on click
    @_map.on 'click', (event) =>
      if @_mapMarker.dragging.enabled()
      # unless @_mapMarker.isLocked()
        offset = $(@_mapDiv).offset()
        newPos =
          x : event.originalEvent.clientX - offset.left
          y : event.originalEvent.clientY - offset.top

        @_mapMarker.setLatLng event.latlng
        # @_mapMarker.setPosition newPos

    # place timeline marker on click
    $(@_timelineDiv).on 'click', (event) =>
      unless @_tlMarker.isLocked()
        offset = $(@_timelineDiv).offset()
        newPos =
          x : event.clientX - offset.left
          y : $(@_timelineDiv).height() - 51

        @_tlMarker.setPosition newPos
        $("#yearDiv").html @_pixelToTime @_tlMarker.getPosition()

    $("#round-end-display").hide();

  questionAnswered: =>
    unless @_questionAnswered
      @_barDiv.removeClass 'animate'
      @_barDiv.css "width", "0%"

      window.clearTimeout @_questionTimeout

      @_questionAnswered = true
      @_currentAnswer.end_time = (new Date()).getTime()
      @showResults()

  showResults: =>
    mapResultPos = @_latLngToPixel @_currentQuestion.latLng

    @_mapResultMarker.setPosition mapResultPos
    @_mapResultMarker.show()
    # @_mapMarker.lock()
    @_mapMarker.dragging.disable()

    tlResultPos = @_timeToPixel(@_currentQuestion.year)
    tlResultPos.y = $(@_timelineDiv).height() - 51
    @_tlResultMarker.setPosition tlResultPos
    @_tlResultMarker.show()
    $("#yearResultDiv").html @_pixelToTime tlResultPos

    @_tlMarker.lock()

    answerLatLng = @_mapMarker.getLatLng()
    # answerLatLng = @_pixelToLatLng @_mapMarker.getPosition()
    spatialDistance = @_getMeterDistance answerLatLng, @_currentQuestion.latLng

    @_mapMarker.opacity = 0.5
    # @_mapMarker.fade()
    @_tlMarker.fade()

    answerTime = @_pixelToTime @_tlMarker.getPosition()
    temporalDistance = Math.abs(answerTime - @_currentQuestion.year)

    $("#answer-location").html @_currentQuestion.location
    $("#answer-year").html @_currentQuestion.year
    $("#answer-spatial-distance").html spatialDistance + " km"
    $("#answer-temporal-distance").html temporalDistance + if temporalDistance is 1 then " Jahr" else " Jahre"
    $("#answer-info").html @_currentQuestion.answer

    spatialSpread = @_getMeterDistance @_map.getBounds().getSouthWest(), @_map.getBounds().getNorthEast()
    spatialScore = 1 - spatialDistance/spatialSpread
    spatialScore = if spatialScore >= @_answerChanceLevel then (spatialScore - @_answerChanceLevel) / (1-@_answerChanceLevel) else 0
    spatialScore = (Math.min(1.0, (spatialScore + 1.0 - @_answerPrecisionThreshold)) - 1.0 + @_answerPrecisionThreshold ) / @_answerPrecisionThreshold

    yearScore = 1 - temporalDistance / (@_currentTimeline.max_year - @_currentTimeline.min_year)
    yearScore = if yearScore >= @_answerChanceLevel then (yearScore - @_answerChanceLevel)/ (1-@_answerChanceLevel) else 0
    yearScore = (Math.min(1.0, (yearScore + 1.0 - @_answerPrecisionThreshold)) - 1.0 + @_answerPrecisionThreshold ) / @_answerPrecisionThreshold

    timeLeft = @_timePerQuestion - (@_currentAnswer.end_time - @_currentAnswer.start_time) / 1000
    timeBonus = 0
    if timeLeft >= (@_timePerQuestion - @_timeBonusThreshold)
      timeBonus = @_maxTimeBonus
    else
      timeBonus = timeLeft / (@_timePerQuestion - @_timeBonusThreshold) * @_maxTimeBonus

    score = Math.round((Math.pow(spatialScore, 3) + Math.pow(yearScore, 3)) / 2 * @_maxScore)

    timeBonus = Math.round(timeBonus/100 * score)

    # $("#answer-score").html score + if score is 1 then " Punkt" else " Punkte"
    # $("#answer-time-bonus").html timeBonus + (if score is 1 then " Punkt" else " Punkte") + " Zeitbonus"

    # score += timeBonus

    $("#answer-total-score").html score + if score is 1 then " Punkt" else " Punkte"
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
      @_currentQuestionRating = null
      $("#next-question").removeClass("invisible");
      $("#submit-answer").addClass("invisible");
      $("#results").animate({height: "show", opacity: "show"});
      $("#question").animate({height: "hide", opacity: "hide"});
      $("#question-number-container").animate({height: "hide", opacity: "hide"});

      if @_questionCount is (@_questionsPerRound + 1)
        $("#submit-answer").addClass("invisible");
        $("#round-end").removeClass("invisible");
    , 2000

  postNewQuestion: =>
    if @_questions?
      unless @_questionCount is (@_questionsPerRound + 1)
        @_resetMarkers()
        @_questionAnswered = false

        # reset loading bar
        @_barDiv.addClass 'animate'
        @_barDiv.css "width", "100%"

        @_mapMarker.opacity = 1.0
        # @_mapMarker.unfade()
        @_tlMarker.unfade()

        $("#question-bar").animate({height: "show", opacity: "show"});
        $("#results").animate({height: "hide", opacity: "hide"});
        $("#question").animate({height: "show", opacity: "show"});
        $("#question-number-container").animate({height: "show", opacity: "show"});

        $("#next-question").addClass("invisible");
        $("#next-round").addClass("invisible");
        $("#round-end").addClass("invisible");
        $("#submit-answer").removeClass("invisible");
        $("#submit-answer").removeClass("disabled");

        newQuestionId = WWWW.TEST_START_ID

        if WWWW.TEST_RUN

          @_currentQuestion = null

          if @_askedQuestions.length > 0
            newQuestionId = @_askedQuestions[@_askedQuestions.length-1]+1

          while @_currentQuestion is null and newQuestionId < 500
            questions = $.grep @_questions, (e) =>
              parseInt(e.id) is newQuestionId
            console.log newQuestionId, questions

            if questions.length > 0
              @_currentQuestion = questions[0]
            else
              newQuestionId += 1

        else
          # search for new question
          newQuestionId = getRandomInt 0, (@_totalQuestionCount - 1)
          while @_askedQuestions.indexOf(newQuestionId) isnt -1
            newQuestionId = getRandomInt 0, (@_totalQuestionCount - 1)

          @_currentQuestion = @_questions[newQuestionId]

        # update question
        @_askedQuestions.push newQuestionId
        @_currentMap = @_maps[@_currentQuestion.map_id]

        @_currentTimeline = @_timelines[0]
        curCenter = (@_currentTimeline.min_year + @_currentTimeline.max_year) * 0.5
        curDist = Math.abs(curCenter - @_currentQuestion.year)/(@_currentTimeline.max_year - @_currentTimeline.min_year)

        for tl in @_timelines
          if tl?
            tlCenter = (tl.min_year + tl.max_year) * 0.5
            dist = Math.abs(tlCenter - @_currentQuestion.year)/(tl.max_year - tl.min_year)

            if dist < curDist
              @_currentTimeline = tl
              curCenter = tlCenter
              curDist = dist


        $("#yearDiv").html @_pixelToTime @_tlMarker.getPosition()
        $('#question').html @_currentQuestion.text
        $('#question-number').html @_questionCount
        $('#questions-per-round').html @_questionsPerRound

        if @_currentQuestion.author? and @_currentQuestion.author isnt ""
          $('#question-author').html "Frage von: " + @_currentQuestion.author
        else
          $('#question-author').html ""

        # calculate random viewport
        pos = @_latLngToPixel
          lat: @_currentQuestion.latLng.lat
          lng: @_currentQuestion.latLng.lng

        paddingTopBottom = 150
        paddingLeftRight = 35

        size = @_map.getSize()
        viewport_width = size.x - paddingLeftRight*2
        viewport_height = size.y - paddingTopBottom*2

        zoom = 3
        scale = 0.5

        # console.log @_currentQuestion.latLng

        # if @_currentQuestion.latLng.lat > 0 and @_currentQuestion.latLng.lat < 90 and
        #    @_currentQuestion.latLng.lng > -20 and @_currentQuestion.latLng.lng < 40

        #   zoom = 4

        fuzzyX = 1 - Math.pow(getRandomFloat(0, 1), 1)
        fuzzyY = 1 - Math.pow(getRandomFloat(0, 1), 1)

        if getRandomInt(0, 1) is 1
          fuzzyX = -fuzzyX

        if getRandomInt(0, 1) is 1
          fuzzyY = -fuzzyY

        target_pos =
          x: pos.x + fuzzyX * viewport_width * scale
          y: pos.y + fuzzyY * viewport_height * scale

        target_pos = @_pixelToLatLng target_pos

        @_map.setView L.latLng(target_pos.lat, target_pos.lng), zoom,
          duration: 0.5
          animate: true

        @_mapMarker.setLatLng L.latLng(target_pos.lat, target_pos.lng)

        # update timeline
        $('#timeline').css "background-image", "url('img/#{@_currentTimeline.file_name}')"

        # hide old result and update result markers
        $("#round-end-display").animate({height: "hide", opacity: "hide"});

        @_mapResultMarker.hide()
        @_mapMarker.dragging.enable()
        # @_mapMarker.release()

        @_tlResultMarker.hide()
        @_tlMarker.release()

        @_currentAnswer.session_id = 0
        @_currentAnswer.start_time = (new Date()).getTime()

        # submit answer when time is up
        @_questionTimeout = window.setTimeout () =>
           @questionAnswered()
        , @_timePerQuestion * 1000

  roundEnd: =>

    $("#total-score").html @_totalScore
    # $("#total-max-score").html @_maxScore * @_questionsPerRound

    $("#results").animate({height: "hide", opacity: "hide"});
    $("#question-bar").animate({height: "hide", opacity: "hide"});
    $("#round-end-display").animate({height: "show", opacity: "show"});

    $("#round-end").addClass("invisible");
    $("#next-round").removeClass("invisible");

    # @_highscoreHandler.update @_totalScore

    @_totalScore = 0
    @_roundCount++
    @_questionCount = 1

    if @_askedQuestions.length is @_totalQuestionCount
      @_askedQuestions = []

  submitAnswer: =>
    @_currentAnswer.session_id = @_session_id
    a = @_currentAnswer
    send =
      table: "answer"
      values: "#{a.q_id}, #{a.round_count}, '#{a.session_id}',
               #{a.lat}, #{a.long}, #{a.year}, #{a.score}, #{a.start_time},
               #{a.end_time}, '#{@_browserDetector.platform}',
               '#{@_browserDetector.browser}', '#{@_browserDetector.version}'"
      names: "`q_id`, `round_count`, `session_id`,
              `lat`, `long`, `year`, `score`, `start_time`,
              `end_time`, `platform`,
              `browser`, `version`"

    WWWW.executePHPFunction "insertIntoDB", send, (response) =>
      console.log "answer was submitted with response #{response}"

  submitRating: =>
    $("#rate-question").raty "reload"
    if @_currentQuestionRating? and not WWWW.DRY_RUN
      send =
        table: "question_rating"
        values: "'#{@_currentAnswer.q_id}', '#{@_session_id}', '#{@_currentQuestionRating}'"
        names: "`q_id`, `session_id`, `rating`"

      WWWW.executePHPFunction "insertIntoDB", send, (response) =>
        console.log "rating was submitted with response #{response}"

  _pixelToLatLng: (pos) =>
    @_map.containerPointToLatLng(L.point(pos.x, pos.y))

  _latLngToPixel: (latLng) =>
    @_map.latLngToContainerPoint(L.latLng(latLng.lat, latLng.lng))

  _getMeterDistance: (latLng1, latLng2) =>
    Math.round(L.latLng(latLng1.lat, latLng1.lng).distanceTo(L.latLng(latLng2.lat, latLng2.lng))/1000)

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

  _resetMarkers: () ->
    # startPos =
    #   x : $(@_mapDiv).width()/2
    #   y : $(@_mapDiv).height()/2
    # @_mapMarker.setPosition startPos
    startPos =
      x : $(@_timelineDiv).width()/2
      y : $(@_timelineDiv).height() - 51
    @_tlMarker.setPosition startPos

  _updateZoomHandle: (zoom) =>

    height = $("#map-zoom-slider").height() - $("#map-zoom-handle-outer").height()
    relativeZoom = 1.0 - zoom / (@_maxZoom - @_minZoom)
    relativePos = relativeZoom * height

    $("#map-zoom-handle-outer").addClass "animate"

    $("#map-zoom-handle-outer").offset
      top: relativePos + $("#map-zoom-slider").offset().top

