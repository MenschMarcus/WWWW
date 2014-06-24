window.WWWW ?= {}


WWWW.executePHPFunction = (method, values, callBack=null) ->
  if (window.XMLHttpRequest)
    xmlhttp = new XMLHttpRequest()
  else
    xmlhttp = new ActiveXObject("Microsoft.XMLHTTP")
  xmlhttp.open( "POST", "./php/execute.php?" + method + "=true", true );
  xmlhttp.setRequestHeader( "Content-Type", "application/json" );
  xmlhttp.send( JSON.stringify(values) );
  xmlhttp.onreadystatechange= =>
    if (xmlhttp.readyState==4 && xmlhttp.status==200)
      callBack? xmlhttp.responseText
