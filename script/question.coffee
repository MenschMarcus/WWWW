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
    @_maxScore = 1000
    @_maxTimeBonus = 10 # in percent of the achieved score
    @_totalScore = 0
    @_roundCount = 1
    @_questionCount = 1
    @_session_id = null
    @_minZoom = 1
    @_maxZoom = 5
    @_startZoom = 3
    @_questionAnswered = false


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
      scrollWheelZoom: "center"
      keyboard: false

    icon_correct = L.icon
      iconUrl: 'img/marker_map.png',
      iconRetinaUrl: 'img/marker_map.png',
      iconSize: [20, 20],
      iconAnchor: [10, 10]

    icon_wrong = L.icon
      iconUrl: 'img/marker_map_result.png',
      iconRetinaUrl: 'img/marker_map_result.png',
      iconSize: [20, 20],
      iconAnchor: [10, 10]

    @_mapMarker = $("#map-marker")
    @_mapResultMarkerCorrect = new L.Marker([50.5, 30.5], {icon:icon_correct}).addTo @_map
    @_mapResultMarkerWrong = new L.Marker([50.5, 30.5], {icon:icon_wrong}).addTo @_map

    @_dontUpdateZoomHandle = false
    @_map.on "zoomend", () =>
      unless @_dontUpdateZoomHandle
        @_updateMapZoomHandle @_map.getZoom()
      @_dontUpdateZoomHandle = false

    @_map.on "moveend", () =>
      unless @_questionAnswered
        latlng = @_map.getCenter()
        pixel = @_map.latLngToContainerPoint latlng
        @_mapMarker.animate {left: pixel.x + "px", top: pixel.y + "px"}
        @_mapResultMarkerCorrect.setLatLng latlng
        @_mapResultMarkerWrong.setLatLng latlng



    @_map.setView([51.505, -0.09], @_startZoom)
    # tiles = L.tileLayer "tiles/{z}/{x}/{y}.png"
    tiles = L.tileLayer "img/tiles/{z}/{x}/{y}.png"
    tiles.addTo @_map
    @_map.attributionControl.setPrefix ''



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

    @_updateMapZoomHandle @_startZoom

    $("#map-zoom-plus").click () =>
      @_map.zoomIn()
      @_updateMapZoomHandle Math.min(@_map.getZoom() + 1, @_maxZoom)

    $("#map-zoom-minus").click () =>
      @_map.zoomOut()
      @_updateMapZoomHandle Math.max(@_map.getZoom() - 1, @_minZoom)


    $("#tl-zoom-handle-outer").draggable
      addClasses: false
      axis: "x"
      containment: "parent"
      drag: (event)=>
        @_updateTimeline()
      stop: (event)=>
        @_updateTimeline()

    $("#tl-zoom-plus").click () =>

      pos = $("#tl-zoom-handle-outer").offset().left -
            $("#tl-zoom-slider").offset().left +
            $("#tl-zoom-handle-outer").width() / 2

      currentYear = @_pixelToTime pos
      new_year = Math.min @_currentTimeline.max_year, currentYear + 1
      new_pos = @_timeToPixel new_year

      $("#tl-zoom-handle-outer").offset
        left : new_pos

      @_updateTimeline()

    $("#tl-zoom-minus").click () =>

      pos = $("#tl-zoom-handle-outer").offset().left -
            $("#tl-zoom-slider").offset().left +
            $("#tl-zoom-handle-outer").width() / 2

      currentYear = @_pixelToTime pos
      new_year = Math.max @_currentTimeline.min_year, currentYear - 1
      new_pos = @_timeToPixel new_year

      $("#tl-zoom-handle-outer").offset
        left : new_pos

      @_updateTimeline()

    $("#tl-zoom-slider").click (event) =>
      $("#tl-zoom-handle-outer").addClass "animate"

      pos = event.pageX -
            $("#tl-zoom-slider").offset().left -
            $("#tl-zoom-handle-outer").width() / 2

      property =
        left: pos

      opts =
        step: () =>
          @_updateTimeline()
        duration : 200

      $("#tl-zoom-handle-outer").animate property, opts


    $("#tl-correct").hide();

    @_barDiv = $('#question-progress')

    @_timePerQuestion = 30 #in seconds

    @_questionTimeout = null

    @_currentAnswer = new WWWW.Answer()

    @_maps = null
    @_currentMap = null

    @_browserDetector = new WWWW.BrowserDetector()



    @_timelines = null
    @_currentTimeline = null

    @_resetMarkers()

    yearResultDiv = document.createElement "div"
    yearResultDiv.id = "yearResultDiv"
    yearResultDiv.className = "yearDiv"

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

    $("#rate-question").raty
      starType: "i"
      hints: ["","","","",""]
      #path : 'script/third-party/raty/images/'
      click: (rating, event) =>
        @_currentQuestionRating = rating

    # place map marker on click
    @_map.on 'click', (event) =>
      offset = $(@_mapDiv).offset()
      newPos =
        x : event.originalEvent.clientX - offset.left
        y : event.originalEvent.clientY - offset.top

      @_map.panTo event.latlng

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

    @_mapResultMarkerCorrect.setOpacity 1.0
    @_mapResultMarkerWrong.setOpacity 1.0
    @_mapResultMarkerCorrect.setLatLng @_currentQuestion.latLng

    $("#tl-correct-year").html @_currentQuestion.year
    $("#tl-chosen").removeClass("center");
    $("#tl-chosen").addClass("right");
    $("#tl-correct").fadeIn();

    answerLatLng = @_map.getCenter()
    spatialDistance = @_getMeterDistance answerLatLng, @_currentQuestion.latLng

    timePos = $("#tl-zoom-handle-outer").offset().left -
              $("#tl-zoom-slider").offset().left +
              $("#tl-zoom-handle-outer").width() / 2

    answerTime = @_pixelToTime timePos
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

    $("#answer-total-score").html score
    $("#answer-total-score-label").html if score is 1 then "Erreichter Punkt" else "Erreichte Punkte"
    $("#answer-max-score").html @_maxScore

    @_totalScore += score

    @_currentAnswer.score = score
    @_currentAnswer.lat = answerLatLng.lat
    @_currentAnswer.long = answerLatLng.lng
    @_currentAnswer.year = answerTime
    @_currentAnswer.round_count = @_roundCount
    @_currentAnswer.q_id = @_currentQuestion.id

    @_questionCount += 1

    $("#submit-answer").hide("fast");
    @_mapMarker.hide();

    unless WWWW.DRY_RUN
      @submitAnswer()

    window.setTimeout () =>
      @_currentQuestionRating = null
      $("#next-question").removeClass("invisible");
      $("#results").animate({height: "show", opacity: "show"});
      $("#answer-info").animate({height: "show", opacity: "show"});
      $("#question").animate({height: "hide", opacity: "hide"});
    , 2000

  postNewQuestion: =>
    if @_questions?
      @_questionAnswered = false

      # reset loading bar
      @_barDiv.addClass 'animate'
      @_barDiv.css "width", "100%"

      $("#results").animate({height: "hide", opacity: "hide"});
      $("#answer-info").animate({height: "hide", opacity: "hide"});
      $("#question").animate({height: "show", opacity: "show"});

      $("#next-question").addClass("invisible");
      $("#next-round").addClass("invisible");
      $("#round-end").addClass("invisible");
      $("#submit-answer").show("fast");

      $("#tl-chosen").removeClass("right");
      $("#tl-chosen").addClass("center");
      $("#tl-correct").fadeOut(0.1);


      newQuestionId = WWWW.TEST_START_ID

      if @_askedQuestions.length is @_totalQuestionCount
        @_askedQuestions = []

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

      @_resetMarkers()

      $('#question').html @_currentQuestion.text
      $('#question-number').html @_questionCount

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

      # @_mapMarker.setLatLng [target_pos.lat, target_pos.lng]

      @_mapMarker.show("fast")
      @_mapResultMarkerCorrect.setOpacity 0.0
      @_mapResultMarkerWrong.setOpacity 0.0


      # @_mapResultMarker.animate {opacity:"hide"}, ()=>
      #   latlng = @_map.getCenter()
      #   pixel = @_map.latLngToContainerPoint latlng
      #   @_mapResultMarker.offset {left: pixel.x, top: pixel.y}

      @_currentAnswer.session_id = 0
      @_currentAnswer.start_time = (new Date()).getTime()

      # submit answer when time is up
      @_questionTimeout = window.setTimeout () =>
         @questionAnswered()
      , @_timePerQuestion * 1000




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
    time = 0

    if @_currentTimeline?
      relX = pos/ $("#tl-zoom-line").width()

      timeDiff = @_currentTimeline.max_year - @_currentTimeline.min_year
      time = Math.round(relX * timeDiff + @_currentTimeline.min_year)

    time


  _timeToPixel: (time) =>
    relTime = (time - @_currentTimeline.min_year) / (@_currentTimeline.max_year - @_currentTimeline.min_year)

    pos = relTime * $("#tl-zoom-line").width() +
          $("#tl-zoom-slider").offset().left  -
          $("#tl-zoom-handle-outer").width() / 2

    pos

  _degToRad: (degree) ->
    return degree * (Math.PI / 180)

  _resetMarkers: () =>
    startPos = $("#tl-zoom-line").width()/2

    $("#tl-zoom-handle-outer").offset
      left : startPos  + $("#tl-zoom-line").offset().left

    @_updateTimeline()

  _updateMapZoomHandle: (zoom) =>

    height = $("#map-zoom-slider").height() - $("#map-zoom-handle-outer").height()
    relativeZoom = 1.0 - (zoom - @_minZoom) / (@_maxZoom - @_minZoom)
    relativePos = relativeZoom * height

    $("#map-zoom-handle-outer").addClass "animate"

    $("#map-zoom-handle-outer").offset
      top: relativePos + $("#map-zoom-slider").offset().top

  _updateTimeline: () =>
    pos = $("#tl-zoom-handle-outer").offset().left -
          $("#tl-zoom-slider").offset().left +
          $("#tl-zoom-handle-outer").width() / 2

    $("#tl-chosen-year").html @_pixelToTime pos


