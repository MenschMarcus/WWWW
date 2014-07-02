<!DOCTYPE html>
<html lang="de">

<?php session_start(); ?>

<head>
  <meta charset="utf-8">

  <script type="text/javascript" src="../script/third-party/jquery-1.10.2.js"></script>
  <script type="text/javascript" src="../script/third-party/jquery-ui-1.10.4.min.js"></script>
  <script type="text/javascript" src="http://maps.googleapis.com/maps/api/js?sensor=false"></script>

  <script type="text/javascript" src="../build/executePHPFunction.js"></script>


  <link rel="stylesheet" type="text/css" href="../style/third-party/bootstrap.css">
  <link rel="stylesheet" type="text/css" href="../style/third-party/bootstrap-theme.css">
  <link rel="stylesheet" type="text/css" href="../style/third-party/bootstrap-social.css">
  <link rel="stylesheet" type="text/css" href="../style/admin.css" />
  <link rel="stylesheet" type="text/css" href="../style/style.css" />
  <link rel="stylesheet" type="text/css" href="../style/marker.css" />
  <link rel="stylesheet" type="text/css" href="../style/feedback.css" />
  <link rel="stylesheet" type="text/css" href="../style/highscores.css" />
  <link rel="stylesheet" type="text/css" href="../style/statistics.css" />

  <link href="../font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css">

  <script language="javascript" type="text/javascript">

    var map;
    var geocoder;
    function InitializeMap() {

        var latlng = new google.maps.LatLng(50.9794934, 11.323543900000004);
        var myOptions =
        {
            zoom: 8,
            center: latlng,
            mapTypeId: google.maps.MapTypeId.ROADMAP,
            disableDefaultUI: true
        };
        map = new google.maps.Map(document.getElementById("map"), myOptions);
    }

    function findLocation() {
        geocoder = new google.maps.Geocoder();
        InitializeMap();

        var lat = parseFloat(document.getElementById("lat").value);
        var lng = parseFloat(document.getElementById("lng").value);
        map.setCenter(new google.maps.LatLng(lat, lng));
        var marker = new google.maps.Marker({
          map: map,
          position: new google.maps.LatLng(lat, lng)
        });
    }

    function findLatLng() {
      geocoder = new google.maps.Geocoder();
      InitializeMap();

      var address = document.getElementById("location").value;
      geocoder.geocode({ 'address': address }, function (results, status) {
          if (status == google.maps.GeocoderStatus.OK) {
              map.setCenter(results[0].geometry.location);
              var marker = new google.maps.Marker({
                  map: map,
                  position: results[0].geometry.location
              });
              document.getElementById("lat").value = results[0].geometry.location.k;
              document.getElementById("lng").value = results[0].geometry.location.B;
          }
          else {
              alert("Ort konnte leider nicht gefunden werden. \n\nError: " + status);
          }
      });
    }

    window.onload = InitializeMap;

    $(document).ready(function($) {
      var fields = []

      $("#sure-cancel").click(
        function() {
          $("#are-you-sure-display").modal('hide');
        }
      );

      $("#sure-send").click(
        function() {
          var send = {
            table: "question_content_contest",
            values: "'"+fields[0].val()+"',"+
                    "'"+fields[3].val()+"',"+
                    "'"+fields[1].val()+"',"+
                    "'"+fields[2].val()+"',"+
                    "'"+fields[4].val()+"',"+
                    "'"+fields[5].val()+"',"+
                    "'"+fields[6].val()+"'",
            names: "`text`, `location`, `lat`, `long`, `year`, `answer`, `group_name`"
          };

          WWWW.executePHPFunction( "insertIntoDB", send,
            function(response) {
              console.log("question submitted with response " + response);
              var len = fields.length;
              for (var i=0; i<len-1; i++) { // IGNORES GROUP NAME FIELD!
                fields[i].val("");
              }
            },
            "./execute.php"
          );
          $("#are-you-sure-display").modal('hide');
        }
      );

      $("#submit").click(
        function() {
          fields[0] = $('textarea[name=question]');
          fields[1] = $('input[name=lat]');
          fields[2] = $('input[name=lng]');
          fields[3] = $('input[name=location]');
          fields[4] = $('input[name=year]');
          fields[5] = $('textarea[name=info]');
          fields[6] = $('input[name=group-name]');

          var allFieldsSet = true;
          var len = fields.length;
          for (var i=0; i<len; i++) {
            if (fields[i].val() == "") {
              allFieldsSet = false;
              break;
            }
          }

          if (allFieldsSet) {
            for (var i=0; i<len; i++) {
              fields[i].parent().removeClass("has-error");
            }

            $("#are-you-sure-display").modal('show');

          } else {
            for (var i=0; i<len; i++) {
              if (fields[i].val() == "") {
                fields[i].parent().addClass("has-error");
              } else {
                fields[i].parent().removeClass("has-error");
              }
            }
          }

        });
      });
  </script>
</head>

<body>
  <div class="stat-group">
    <br/>
    <div id="location-group" class="form-group col-xs-12 floating-label-form-group">
      <label class="control-label" for="location">Gruppenname</label>
      <input id="location" class="form-control" type="text" name="group-name" placeholder="Name eurer Gruppe">
    </div>
    <br/>
    <div id="question-group" class="form-group col-xs-12 floating-label-form-group">
      <label class="control-label" for="question">Fragetext</label>
      <textarea name="question" placeholder="Fragetext" class="form-control" rows="5"></textarea>
    </div>
    <br/>
    <table class="map-table">
      <tr>
        <td>
          <div id="location-group" class="form-group col-xs-12 floating-label-form-group">
            <label class="control-label" for="location">Antwort Ort</label>
            <input id="location" class="form-control" type="text" name="location" placeholder="Ort">
          </div>
          <br />
          <input id="Button1" class="btn btn-default" type="button" value="Finde Ort" onclick="return findLatLng()" />
          <br/>
          <div id="lat-group" class="form-group col-xs-12 floating-label-form-group">
            <label class="control-label" for="lat">Antwort Latitude</label>
            <input id="lat" class="form-control" type="text" name="lat" placeholder="Latitude">
          </div>
          <br/>
          <div id="lng-group" class="form-group col-xs-12 floating-label-form-group">
            <label class="control-label" for="lng">Antwort Longitude</label>
            <input id="lng" class="form-control" type="text" name="lng" placeholder="Longitude">
          </div>
          <br />
          <input id="Button1" class="btn btn-default" type="button" value="Finde Koordinaten" onclick="return findLocation()" />
        </td>
        <td>
          <div id="map"></div>
        </td>
      </tr>
    </table>
    <br/>
    <div id="year-group" class="form-group col-xs-12 floating-label-form-group">
      <label class="control-label" for="year">Antwort Jahr</label>
      <input id="year" class="form-control" type="text" name="year" placeholder="Jahr">
    </div>
    <div id="info-group" class="form-group col-xs-12 floating-label-form-group">
      <label class="control-label" for="info">Infotext</label>
      <textarea id="info" name="info" placeholder="Infotext" class="form-control" rows="5"></textarea>
    </div>

    <br/>

    <div id="submit" class="btn btn-success">Abschicken!</div>
  </div>

  <div id="are-you-sure-display" class="modal fade" data-backdrop="static" data-keyboard="false" tabindex="-1" role="dialog" aria-labelledby="mySmallModalLabel" aria-hidden="true">
    <div class="modal-dialog">
      <div class="modal-content">
        <div class="modal-header">
          <h4 class="modal-title">Wirklich abschicken?</h4>
        </div>
        <div class="modal-body">
          <!-- Denk dran: Für eine Korrektur musst du dich erst auf dem Server einloggen und 1000000 Mal klicken, bevor du an der richten Stelle bist! -->
          <br/>
          Hast du...
          <br/>
          ... die Rechtschreibung geprüft?
          <br/>
          ... die korrekten Koordinaten und Vorzeichen bei Latitude und Longitude eingetragen?

        </div>
        <div class="modal-footer">
          <div id="sure-cancel" class="btn btn-lg btn-danger">Ich schaue lieber nochmal...</div>
          <div id="sure-send" class="btn btn-lg btn-success">Ja, verdammt!</div>
        </div>
      </div>
    </div>
  </div>

   <script src="../script/third-party/bootstrap.min.js"></script>
</body>

</html>
