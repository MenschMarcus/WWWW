window.WWWW ?= {}

class WWWW.HighscoreHandler

  constructor: ->
  	@score_list = {}

  update: (own_score)=>
  	WWWW.executePHPFunction "getScoreList", null, (response) =>
  		@score_list = JSON.parse(response)
  		add_at = @score_list.length
  		for score_obj, i in @score_list
  			if parseInt(score_obj.score) > own_score
  				add_at = i
  		@score_list.splice(i, 0, "Lene");
  		console.log @score_list

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
