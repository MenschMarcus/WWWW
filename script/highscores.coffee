window.WWWW ?= {}

class WWWW.HighscoreHandler

  constructor: ->

  getScoreList: =>
  	WWWW.executePHPFunction "getScoreList", null, (response) =>
  		list = JSON.parse(response)