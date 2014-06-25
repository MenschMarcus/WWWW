window.WWWW ?= {}

class WWWW.HighscoreHandler

  constructor: ->
  	@_score_list = {}


  getScoreList: =>
  	WWWW.executePHPFunction "getScoreList", null, (response) =>
  		@_score_list = JSON.parse(response)

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
