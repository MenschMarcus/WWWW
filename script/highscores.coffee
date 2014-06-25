window.WWWW ?= {}

class WWWW.HighscoreHandler

  constructor: ->
    $("#name-email-display").hide()
    @score_list = []
    @_nameEmailShown = false

  update: (own_score)=>
    WWWW.executePHPFunction "getScoreList", null, (response) =>
      $("#highscore-list").empty()

      nameButton = document.createElement "div"
      $(nameButton).html "Deinen Namen eintragen!"
      nameButton.className = "btn btn-success"

      nameEmailDisplay = $("#name-email-display")

      $(nameButton).popover
        html: true,
        title: "Bitte Name und Email-Adresse eintragen!",
        content: nameEmailDisplay,
        placement: "top"
        container: "#round-end-display"
        trigger: "manual"

      $(nameButton).click () =>
        unless @_nameEmailShown
          nameEmailDisplay.show()
          $(nameButton).popover "show"
          @_nameEmailShown = true

      $("#submit-name-email").click ()=>
        name = $('input[name=name]').val()
        email = $('input[name=email]').val()

        if name isnt "" and email isnt ""
          $(nameButton).html name
          nameButton.className = ""
          $(nameButton).popover "hide"

        #   send =
        #     table: "feedback"
        #     values: "'#{session_id}', '#{message}'"
        #     names: "`session_id`, `message`"

        #   WWWW.executePHPFunction "insertIntoDB", send, (response) =>
        #     @_feedbackSubmitted = true
        #     console.log "Feedback was submitted with response #{response}"
        #     $("#feedback-fail").slideUp()
        #     $("#feedback-answer").hide().slideDown()


      $("#next-round").click () =>
        @_nameEmailShown = false
        $("body").append nameEmailDisplay
        nameEmailDisplay.hide()
        $(nameButton).popover "hide"

      @score_list = JSON.parse(response)
      add_at = @score_list.length
      for score_obj, i in @score_list
      	score_obj.score = parseInt(score_obj.score)
      	if score_obj.score < own_score
      		add_at = i
      		break

      @score_list.splice add_at, 0,
      	nickname: nameButton
      	score: own_score

      for score_obj, i in @score_list
      	@_postRow i + 1, score_obj.nickname, score_obj.score

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
