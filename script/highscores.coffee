window.WWWW ?= {}

class WWWW.HighscoreHandler

  constructor: ->
  	@score_list = []

  update: (own_score)=>
  	WWWW.executePHPFunction "getScoreList", null, (response) =>
      $("#highscore-list").empty()

      nameButton = document.createElement "div"
      $(nameButton).html "Eintragen!"
      nameButton.className = "btn btn-success"

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
