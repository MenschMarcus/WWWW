executePHPFunction: (method, values, callBack=null) ->
        $("#loading_popup").fadeIn()
        if (window.XMLHttpRequest)
            xmlhttp = new XMLHttpRequest()
        else
            xmlhttp = new ActiveXObject("Microsoft.XMLHTTP")

        xmlhttp.open( "POST", "execute.php?" + method + "=true", true );
        xmlhttp.setRequestHeader( "Content-Type", "application/json" );
        xmlhttp.send( JSON.stringify(values) );

        xmlhttp.onreadystatechange= =>
            if (xmlhttp.readyState==4 && xmlhttp.status==200)
                callBack? xmlhttp.responseText
                $("#loading_popup").fadeOut()
