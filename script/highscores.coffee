window.WWWW ?= {}

class WWWW.HighscoreHandler

  constructor: ->
    $("#name-email-display").hide()
    @score_list = []
    @_nameEmailShown = false

  update: (currentScore)=>
    WWWW.executePHPFunction "getScoreList", null, (response) =>
      $("#highscore-list").empty()

      nameButton = document.createElement "div"
      $(nameButton).html "Deinen Namen eintragen!"
      nameButton.className = "btn btn-success"

      nameEmailDisplay = $("#name-email-display")

      $(nameButton).popover
        html: true,
        title: "Bitte trage Name und Email-Adresse ein!",
        content: nameEmailDisplay,
        placement: "top"
        container: "#round-end-display"
        trigger: "manual"

      $(nameButton).click () =>
        unless @_nameEmailShown
          nameEmailDisplay.show()
          $(nameButton).popover "show"
          @_nameEmailShown = true
        else
          $(nameButton).popover "hide"
          @_nameEmailShown = false

      $("#submit-name-email").click ()=>
        name = $('input[name=name]').val()
        email = $('input[name=email]').val()

        if name isnt "" and email isnt ""
          $("#name-group").removeClass "has-error"
          $("#email-group").removeClass "has-error"
          $(nameButton).html name
          nameButton.className = ""
          $(nameButton).popover "hide"

          send =
            table: "score"
            values: "'#{name}', '#{email}', '#{currentScore}'"
            names: "`nickname`, `email`, `score`"

          WWWW.executePHPFunction "insertIntoDB", send, (response) =>
            console.log "highscore was submitted with response #{response}"

        else
          if name is ""
            $("#name-group").addClass "has-error"
          if email is ""
            $("#email-group").addClass "has-error"



      $("#next-round").click () =>
        @_nameEmailShown = false
        $("body").append nameEmailDisplay
        nameEmailDisplay.hide()
        $(nameButton).popover "hide"

      @score_list = JSON.parse(response)
      add_at = @score_list.length
      for score_obj, i in @score_list
      	score_obj.score = parseInt(score_obj.score)
      	if score_obj.score < currentScore
      		add_at = i
      		break

      @score_list.splice add_at, 0,
      	nickname: nameButton
      	score: currentScore

      for score_obj, i in @score_list
      	@_postRow i + 1, score_obj.nickname, score_obj.score

      window.setTimeout () =>
        offset = $(nameButton).offset().top
        parent = $('#hsc-scroll-table').offset().top
        $('#hsc-scroll-table').animate({scrollTop:offset - parent - 100}, 1500)
      , 1500



  _postRow: (rank, name, score) ->
    row = document.createElement "tr"
    row.className = "table-striped"
    rankCol = document.createElement "td"
    nameCol = document.createElement "td"
    scoreCol = document.createElement "td"

    row.appendChild rankCol
    row.appendChild nameCol
    row.appendChild scoreCol

    $(rankCol).html rank
    $(nameCol).html name
    $(scoreCol).html score

    $("#highscore-list").append row

