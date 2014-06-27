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
      $("#submit").click(
        function() {
          var question = $('input[name=question]').val()
          var lat = $('input[name=lat]').val()
          var lng = $('input[name=lng]').val()
          var year = $('input[name=year]').val()
          var info = $('input[name=info]').val()

          if (question != "" && lat != "" && lng != "" && year != "" && info != "")
            var send = {
              table: "question_testing",
              // values: "'#{@_session_id}', #{send.funny}"
              // names: "`session_id`, `funny`"
            };

            WWWW.executePHPFunction( "manualSQLQuery", send,
              function(response) {
                // console.log(response);
              },
              "./execute.php"
            );

        });
      });
  </script>
</head>

<body>
  <div class="stat-group">
    <div id="question-group" class="form-group col-xs-12 floating-label-form-group">
      <label class="control-label" for="question">Fragetext</label>
      <textarea id="question" name="question" placeholder="Fragetext" class="form-control" rows="5"></textarea>
    </div>
    <br/>
    <div  id="lat-group" class="form-group col-xs-12 floating-label-form-group">
      <label class="control-label" for="lat">Antwort Latitude</label>
      <input id="lat" class="form-control" type="text" name="lat" placeholder="Latitude">
    </div>
    <br/>
    <div  id="lng-group" class="form-group col-xs-12 floating-label-form-group">
      <label class="control-label" for="lng">Antwort Longitude</label>
      <input id="lng" class="form-control" type="text" name="lng" placeholder="Longitude">
    </div>
    <br/>
    <div  id="year-group" class="form-group col-xs-12 floating-label-form-group">
      <label class="control-label" for="year">Antwort Jahr</label>
      <input id="year" class="form-control" type="text" name="year" placeholder="Jahr">
    </div>
    <div id="info-group" class="form-group col-xs-12 floating-label-form-group">
      <label class="control-label" for="info">Infotext</label>
      <textarea id="info" name="info" placeholder="Infotext" class="form-control" rows="5"></textarea>
    </div>

    <button id="submit" type="submit_button" class="btn btn-success">Los!</button>
  </div>

   <script src="../js/bootstrap.min.js"></script>
</body>

</html>
