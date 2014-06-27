<!DOCTYPE html>
<html lang="de">

<?php session_start(); ?>

<head>
  <meta charset="utf-8">

  <script type="text/javascript" src="../script/third-party/jquery-1.10.2.js"></script>
  <script type="text/javascript" src="../script/third-party/jquery-ui-1.10.4.min.js"></script>

  <script type="text/javascript" src="../build/executePHPFunction.js"></script>


  <link rel="stylesheet" type="text/css" href="../style/bootstrap.css">
  <link rel="stylesheet" type="text/css" href="../style/bootstrap-theme.css">
  <link rel="stylesheet" type="text/css" href="../style/bootstrap-social.css">
  <link rel="stylesheet" type="text/css" href="../style/style.css" />
  <link rel="stylesheet" type="text/css" href="../style/marker.css" />
  <link rel="stylesheet" type="text/css" href="../style/feedback.css" />
  <link rel="stylesheet" type="text/css" href="../style/highscores.css" />
  <link rel="stylesheet" type="text/css" href="../style/statistics.css" />

  <link href="../font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css">

  <script type="text/javascript">
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
            table: "question",
            values: "'"+fields[0].val()+"',"+
                    "'"+fields[7].val()+"',"+
                    "'"+fields[6].val()+"',"+
                    "'"+fields[3].val()+"',"+
                    "'"+fields[1].val()+"',"+
                    "'"+fields[2].val()+"',"+
                    "'"+fields[4].val()+"',"+
                    "'"+(fields[8].prop("checked") ? 1 : 0) +"',"+
                    "'"+fields[5].val()+"'",
            names: "`text`, `map_id`, `tl_id`, `location`, `lat`, `long`, `year`, `funny`, `answer`"
          };

          WWWW.executePHPFunction( "insertIntoDB", send,
            function(response) {
              console.log("question submitted with response " + response);
              var len = fields.length;
              for (var i=0; i<len; i++) {
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
          fields[6] = $('input[name=timeline]');
          fields[7] = $('input[name=map]');
          fields[8] = $('input[name=funny]');

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
    <div id="question-group" class="form-group col-xs-12 floating-label-form-group">
      <label class="control-label" for="question">Fragetext</label>
      <textarea name="question" placeholder="Fragetext" class="form-control" rows="5"></textarea>
    </div>
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
    <br/>
    <div id="location-group" class="form-group col-xs-12 floating-label-form-group">
      <label class="control-label" for="location">Antwort Ort</label>
      <input id="location" class="form-control" type="text" name="location" placeholder="Ort">
    </div>
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
    <div id="map-group" class="form-group col-xs-12 floating-label-form-group">
      <label class="control-label" for="map">Karten ID</label>
      <input id="map" class="form-control" type="text" name="map" placeholder="Karten ID">
    </div>
    <br/>
    <div id="timeline-group" class="form-group col-xs-12 floating-label-form-group">
      <label class="control-label" for="timeline">Zeitleisten ID</label>
      <input id="timeline" class="form-control" type="text" name="timeline" placeholder="Zeitleisten ID">
    </div>
    <br/>
    <div id="funny-group" class="form-group col-xs-12 floating-label-form-group">

      <label for="funny">
        <input id="funny" type="checkbox" name="funny"> Kuriose Frage
      </label>
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
          Denk dran: Für eine Korrektur musst du dich erst auf dem Server einloggen und 1000000 Mal klicken, bevor du an der richten Stelle bist!
          <br/>
          Also hast du...
          <br/>
          ... die Rechtschreibung geprüft?
          <br/>
          ... die korrekten Koordinaten und Vorzeichen bei Latitude und Longitude eingetragen?
          <br/>
          ... die richtigen IDs für Karte und Zeitleiste angegeben?
          <br/>
          ... angehakt, ob die Frage kurios ist oder nicht?

        </div>
        <div class="modal-footer">
          <div id="sure-cancel" class="btn btn-lg btn-danger">Ich schaue lieber nochmal...</div>
          <div id="sure-send" class="btn btn-lg btn-success">Ja, verdammt!</div>
        </div>
      </div>
    </div>
  </div>

   <script src="../js/bootstrap.min.js"></script>
</body>

</html>
