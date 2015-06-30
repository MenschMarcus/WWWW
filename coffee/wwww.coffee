window.WWWW ?= {}

settings.title_id = "CC05"

WWWW.setCookie = (cname, cvalue, exdays) ->
  d = new Date()
  d.setTime (d.getTime() + (exdays*24*60*60*1000))
  expires = "expires=" + d.toUTCString()
  document.cookie = cname + "=" + cvalue + "; " + expires

WWWW.getCookie = (cname) ->
  name = cname + "="
  ca = document.cookie.split ';'
  for c in ca
    while c.charAt(0) == ' '
      c = c.substring 1

    if c.indexOf(name) == 0
      return c.substring name.length, c.length

  return ""
