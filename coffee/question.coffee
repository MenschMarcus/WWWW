window.WWWW ?= {}

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
    @_minZoom = 1
    @_maxZoom = 5
    @_startZoom = 3
    @_questionAnswered = false

    @_answerPrecisionThreshold = 0.9 # time and space need to be 95% correct to achieve the maximum score
    @_answerChanceLevel = 0.8 # time and space need to be at least 75% correct to score any point
    @_answerMaxDistance = 10000 # km

    @_mapDiv = document.getElementById("map")
    @_map = L.map 'map',
      minZoom: @_minZoom
      maxZoom: @_maxZoom
      zoomControl: false
      dragging: true
      touchZoom: true
      scrollWheelZoom: false
      doubleClickZoom: true
      worldCopyJump: true
      bounceAtZoomLimits: false
      boxZoom: false
      keyboard: false

    icon_correct = L.icon
      iconUrl: 'img/marker.png',
      iconRetinaUrl: 'img/marker.png',
      iconSize: [20, 20],
      iconAnchor: [10, 10]

    icon_wrong = L.icon
      iconUrl: 'img/marker_result.png',
      iconRetinaUrl: 'img/marker_result.png',
      iconSize: [20, 20],
      iconAnchor: [10, 10]

    @_mapMarker = $("#map-marker")
    @_mapMarker.hide()
    @_mapResultMarkerCorrect = new L.Marker([50.5, 30.5], {icon:icon_correct}).addTo @_map
    @_mapResultMarkerWrong = new L.Marker([50.5, 30.5], {icon:icon_wrong}).addTo @_map

    $('#map').on 'mousewheel', (event) =>
      event.preventDefault()
      if (event.deltaY > 0 and @_map.getZoom() < @_maxZoom)
        @_map.setZoomAround @_mapResultMarkerCorrect.getLatLng(), @_map.getZoom()+1
      else if (event.deltaY < 0 and @_map.getZoom() > @_minZoom)
        @_map.setZoomAround @_mapResultMarkerCorrect.getLatLng(), @_map.getZoom()-1

    @_dontUpdateZoomHandle = false
    @_map.on "zoomend", () =>
      unless @_dontUpdateZoomHandle
        @_updateMapZoomHandle @_map.getZoom()
      @_dontUpdateZoomHandle = false

    @_map.on "moveend", () =>
      unless @_questionAnswered
        pos = L.point($(window).width()*0.5, $(window).height()*0.6);
        latlng = @_map.containerPointToLatLng pos
        @_mapMarker.animate {left: pos.x + "px", top: pos.y + "px"}
        @_mapResultMarkerCorrect.setLatLng latlng
        @_mapResultMarkerWrong.setLatLng latlng


    @_map.setView([51.505, -0.09], @_startZoom)
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
        @_updateTime()
      stop: (event)=>
        @_updateTime()

    $("#tl-zoom-plus").click () =>
      unless @_questionAnswered
        pos = $("#tl-zoom-handle-outer").offset().left -
              $("#tl-zoom-slider").offset().left

        currentYear = @_pixelToTime pos
        new_year = Math.min @_timeline.max_year, currentYear + 1
        new_pos = @_timeToPixel new_year

        $("#tl-zoom-handle-outer").offset
          left : new_pos

        @_updateTime()

    $("#tl-zoom-minus").click () =>
      unless @_questionAnswered
        pos = $("#tl-zoom-handle-outer").offset().left -
              $("#tl-zoom-slider").offset().left

        currentYear = @_pixelToTime pos
        new_year = Math.max @_timeline.min_year, currentYear - 1
        new_pos = @_timeToPixel new_year

        $("#tl-zoom-handle-outer").offset
          left : new_pos

        @_updateTime()


    $("#tl-zoom-slider").click (event) =>
      unless @_questionAnswered
        pos = event.pageX -
              $("#tl-zoom-slider").offset().left -
              $("#tl-zoom-handle-outer").outerWidth() / 2

        new_year = @_pixelToTime pos
        new_year = Math.max Math.min(new_year, @_timeline.max_year), @_timeline.min_year
        new_pos = @_timeToPixel new_year
        new_pos -= $("#tl-zoom-slider").offset().left

        property =
          left: new_pos

        opts =
          step: () =>
            @_updateTime()
          duration : 200

        $("#tl-zoom-handle-outer").animate property, opts


    $("#tl-correct").hide()
    $("#tl-zoom-handle-outer").hide()
    $("#tl-zoom-handle-outer-answer").hide()
    $("#tl-zoom-handle-outer-result").hide()

    @_barDiv = $('#question-progress')

    @_timePerQuestion = 30 #in seconds

    @_questionTimeout = null

    @_currentAnswer = new WWWW.Answer()

    @_timeline = null

    # @_resetMarkers()

    yearResultDiv = document.createElement "div"
    yearResultDiv.id = "yearResultDiv"
    yearResultDiv.className = "yearDiv"

    $.ajax
      url: "data/question.csv"
      dataType: "text"
      success: (csvd) =>
        @_questions = $.csv.toObjects csvd,
          separator: '|'
        for question, i in @_questions
          question.latLng =
            lat : parseFloat(question.lat)
            lng : parseFloat(question.long)
        @_totalQuestionCount = @_questions?.length
        # @postNewQuestion()

    # submit answer on click
    $('#submit-answer').on 'click', () =>
      @questionAnswered()

    # post new question on click
    $('#next-question').on 'click', () =>
      @postNewQuestion()

    $('#abort').on 'click', () =>
      $("#title-screen").fadeIn();

    # post new question on click
    $('#next-round').on 'click', () =>
      @postNewQuestion()

    $("#round-end-display").hide();

  run: =>
    $("#tl-zoom-handle-outer").show()
    @_mapMarker.show()
    @postNewQuestion()

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

    @_map.fitBounds [@_currentQuestion.latLng, @_mapResultMarkerWrong.getLatLng()],
      padding: [20, 300]


    currentPos = $("#tl-zoom-handle-outer").offset()

    answerLatLng = @_mapResultMarkerWrong.getLatLng()
    spatialDistance = @_getMeterDistance answerLatLng, @_currentQuestion.latLng

    timePos = $("#tl-zoom-handle-outer").offset().left -
              $("#tl-zoom-slider").offset().left

    answerTime = @_pixelToTime timePos
    tlResultPos = @_timeToPixel @_currentQuestion.year

    temporalDistance = Math.abs(answerTime - @_currentQuestion.year)
    $("#tl-zoom-handle-outer-answer").fadeIn()
    $("#tl-zoom-handle-outer-answer").offset currentPos
    $("#tl-zoom-handle-outer-result").fadeIn()
    $("#tl-zoom-handle-outer-result").offset
      top : currentPos.top
      left : tlResultPos

    $("#tl-zoom-handle-outer").hide()

    $("#answer-location").html @_currentQuestion.location
    $("#answer-year").html @_timeToString @_currentQuestion.year, false
    $("#answer-spatial-distance").html spatialDistance + " km"
    $("#answer-temporal-distance").html temporalDistance + if temporalDistance is 1 then " Jahr" else " Jahre"
    $("#answer-info").html @_currentQuestion.answer

    $("#tl-correct-year").html @_timeToString @_currentQuestion.year, true
    $("#tl-chosen").removeClass("center");

    if answerTime - @_currentQuestion.year >= 0
      $("#tl-chosen").addClass("right");
      $("#tl-correct").addClass("left");
    else
      $("#tl-chosen").addClass("left");
      $("#tl-correct").addClass("right");

    $("#tl-correct").fadeIn();

    spatialScore = 1 - spatialDistance/@_answerMaxDistance
    spatialScore = if spatialScore >= @_answerChanceLevel then (spatialScore - @_answerChanceLevel) / (1-@_answerChanceLevel) else 0
    spatialScore = (Math.min(1.0, (spatialScore + 1.0 - @_answerPrecisionThreshold)) - 1.0 + @_answerPrecisionThreshold ) / @_answerPrecisionThreshold

    yearScore = 1 - temporalDistance / (@_timeline.max_year - @_timeline.min_year)
    yearScore = if yearScore >= @_answerChanceLevel then (yearScore - @_answerChanceLevel)/ (1-@_answerChanceLevel) else 0
    yearScore = (Math.min(1.0, (yearScore + 1.0 - @_answerPrecisionThreshold)) - 1.0 + @_answerPrecisionThreshold ) / @_answerPrecisionThreshold

    score = Math.round((Math.pow(spatialScore, 3) + Math.pow(yearScore, 3)) / 2 * @_maxScore)

    $("#answer-total-score").html score
    $("#answer-max-score").html @_maxScore

    @_totalScore += score

    @_currentAnswer.score = score
    @_currentAnswer.lat = answerLatLng.lat
    @_currentAnswer.long = answerLatLng.lng
    @_currentAnswer.year = answerTime
    @_currentAnswer.round_count = @_roundCount
    @_currentAnswer.q_id = @_currentQuestion.id

    if exports.settings.session_ticket?
      idString = "q_#{@_currentQuestion.id}"

      scoreRequest = {}
      scoreRequest["Keys"] = [idString]
      exports.client.GetUserData scoreRequest,
        (error, result) =>
          console.log "Retrieving score data"
          console.log "Error: ", error
          console.log "Response: ", result

          previousScore = 0
          if result?.Data[idString]?.Value?
            previousScore = result.Data[idString].Value
            $("#answer-previous-score").html "Dein Bestes: #{previousScore}"


          if score > previousScore
            udpateRequest = {}
            udpateRequest["Data"] = {}
            udpateRequest["Data"][idString] = "#{score}"

            exports.client.UpdateUserData udpateRequest,
              (error, result) =>
                console.log "Updating user data"
                console.log "Error: ", error
                console.log "Response: ", result

    @_questionCount += 1

    $("#submit-answer").addClass("hidden");
    @_mapMarker.hide();

    window.setTimeout () =>
      @_currentQuestionRating = null

      hidePos = -$("#question").outerHeight() - 9 + "px"

      $("#top-bar").css({
        '-webkit-transform' : 'translateY(' + hidePos + ')',
        '-moz-transform'    : 'translateY(' + hidePos + ')',
        '-ms-transform'     : 'translateY(' + hidePos + ')',
        '-o-transform'      : 'translateY(' + hidePos + ')',
        'transform'         : 'translateY(' + hidePos + ')'
      });
      $("#results").removeClass("hidden");
    , 2000

  postNewQuestion: =>
    if @_questions?
      @_questionAnswered = false

      # reset loading bar
      @_barDiv.addClass 'animate'
      @_barDiv.css "width", "100%"

      $("#results").addClass("hidden");

      $("#top-bar").css({
        '-webkit-transform' : 'translateY(0px)',
        '-moz-transform'    : 'translateY(0px)',
        '-ms-transform'     : 'translateY(0px)',
        '-o-transform'      : 'translateY(0px)',
        'transform'         : 'translateY(0px)'
      });

      $("#submit-answer").removeClass("hidden");

      $("#tl-chosen").removeClass("right");
      $("#tl-chosen").removeClass("left");
      $("#tl-correct").removeClass("right");
      $("#tl-correct").removeClass("left");
      $("#tl-chosen").addClass("center");
      $("#tl-correct").fadeOut(0.1);


      newQuestionIndex = WWWW.TEST_START_ID

      if @_askedQuestions.length is @_totalQuestionCount
        @_askedQuestions = []

      if WWWW.TEST_RUN

        @_currentQuestion = null

        if @_askedQuestions.length > 0
          newQuestionIndex = @_askedQuestions[@_askedQuestions.length-1]+1

        while @_currentQuestion is null and newQuestionIndex < 500
          questions = $.grep @_questions, (e) =>
            parseInt(e.id) is newQuestionIndex

          if questions.length > 0
            @_currentQuestion = questions[0]
          else
            newQuestionIndex += 1

      else
        # search for new question
        newQuestionIndex = getRandomInt 0, (@_totalQuestionCount - 1)
        while @_askedQuestions.indexOf(newQuestionIndex) isnt -1
          newQuestionIndex = getRandomInt 0, (@_totalQuestionCount - 1)

        @_currentQuestion = @_questions[newQuestionIndex]

      # update question year

      @_currentQuestion.year = parseInt @_currentQuestion.year  # prevents adding "1" to string
      if @_currentQuestion.year < 0
        @_currentQuestion.year += 1

      # update question
      @_askedQuestions.push newQuestionIndex

      # increase timeline range
      timeRange = -1*Math.min(0, parseInt(@_currentQuestion.year) - 2000) + 50
      timeShift = getRandomFloat(0.1, 0.9)

      @_timeline =
        min_year: Math.floor(parseInt(@_currentQuestion.year) - timeRange*timeShift)
        max_year: Math.ceil(parseInt(@_currentQuestion.year) + timeRange*(1-timeShift))

      @_resetMarkers()

      $('#question').html @_currentQuestion.text

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

      @_currentAnswer.start_time = (new Date()).getTime()

      # submit answer when time is up
      @_questionTimeout = window.setTimeout () =>
         @questionAnswered()
      , @_timePerQuestion * 1000



  _pixelToLatLng: (pos) =>
    @_map.containerPointToLatLng(L.point(pos.x, pos.y))

  _latLngToPixel: (latLng) =>
    @_map.latLngToContainerPoint(L.latLng(latLng.lat, latLng.lng))

  _getMeterDistance: (latLng1, latLng2) =>
    Math.round(L.latLng(latLng1.lat, latLng1.lng).distanceTo(L.latLng(latLng2.lat, latLng2.lng))/1000)

  _pixelToTime: (pos) =>
    time = 0

    if @_timeline?
      relX = pos / ($("#tl-zoom-line").width() - $("#tl-zoom-handle-outer").width())

      timeDiff = @_timeline.max_year - @_timeline.min_year
      time = Math.round(relX * timeDiff + @_timeline.min_year)

    time


  _timeToPixel: (time) =>
    relTime = (time - @_timeline.min_year) / (@_timeline.max_year - @_timeline.min_year)

    pos = relTime * ($("#tl-zoom-line").width() - $("#tl-zoom-handle-outer").width()) +
          $("#tl-zoom-slider").offset().left

    pos

  _degToRad: (degree) ->
    return degree * (Math.PI / 180)

  _timeToString: (time, small) =>
    if time < 1
      if small
        -(time-1) + "<span style='font-size:0.35em; font-weight:300'> v. Chr.</span>"
      else
        -(time-1) + " v. Chr."
    else
      time + ""

  _resetMarkers: () =>
    $("#tl-zoom-handle-outer").show()
    $("#tl-zoom-handle-outer-answer").hide()
    $("#tl-zoom-handle-outer-result").hide()

    startPos = $("#tl-zoom-line").width()/2 - $("#tl-zoom-handle-outer").outerWidth()/2

    $("#tl-zoom-handle-outer").offset
      left : startPos + $("#tl-zoom-line").offset().left

    @_updateTime()

  _updateMapZoomHandle: (zoom) =>

    # height = $("#map-zoom-slider").height() - $("#map-zoom-handle-outer").height()
    # relativeZoom = 1.0 - (zoom - @_minZoom) / (@_maxZoom - @_minZoom)
    # relativePos = relativeZoom * height

    # $("#map-zoom-handle-outer").addClass "animate"

    # $("#map-zoom-handle-outer").offset
    #   top: relativePos + $("#map-zoom-slider").offset().top

  _updateTime: () =>
    pos = $("#tl-zoom-handle-outer").offset().left -
          $("#tl-zoom-slider").offset().left

    year = @_pixelToTime pos

    $("#tl-chosen-year").html @_timeToString year, true


