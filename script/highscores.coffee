window.WWWW ?= {}

class WWWW.HighscoreHandler

  constructor: ->
  	@_score_list = {}

  getScoreList: =>
  	WWWW.executePHPFunction "getScoreList", null, (response) =>
  		@_score_list = JSON.parse(response)