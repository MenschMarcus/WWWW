<!DOCTYPE html>
<html lang="de">

<?php session_start(); ?>

<head>
  <meta charset="utf-8">

  <script type="text/javascript" src="script/third-party/jquery-1.10.2.js"></script>
  <script type="text/javascript" src="script/third-party/jquery-ui-1.10.4.min.js"></script>
  <script type="text/javascript" src="build/question.js"></script>
  <script type="text/javascript" src="build/marker.js"></script>

  <link rel="stylesheet" type="text/css" href="style/bootstrap.css">
  <link rel="stylesheet" type="text/css" href="style/bootstrap-theme.css">
  <link rel="stylesheet" type="text/css" href="style/style.css" />
  <link rel="stylesheet" type="text/css" href="style/marker.css" />

  <script type="text/javascript">
    $(document).ready(function($) {
      var theapp = new WWWW.QuestionHandler();

      $('#question-progress').css({width:'100%'});

    });
  </script>
</head>

<body>
    <div class="phone-outer">
        <div class="phone-inner">
            <div class="timeline" id="timeline"></div>
            <div class="map" id="map"></div>
            <div class="question-bar">
                <div class="text-center">Frage <span id="question-number">1</span>/<span id="questions-per-round'">5</span>:</div>
                <div id="question"></div>
                <div id="results" class="text-center">
                  <div id="score">
                    <h1><span id="answer-score"></span> Punkte!</h1>
                    <div><span id="answer-location"></span>, <span id="answer-year"></span></div>
                    <div>Distanz: <span id="answer-spatial-distance"></span> / <span id="answer-temporal-distance"></span></div>
                  </div>
                  <div id="answer-info"></div>
                </div>
            </div>
            <div class="control-bar">
                <div id="question-progress" class="question-progress animate"></div>
                <div id="count-down" class="count-down"></div>
                <button type="button" data-toggle="modal" data-target="#abort-dialog" class="btn btn-danger abort btn-lg"><span class="glyphicon glyphicon-remove"></span></button>
                <div id="submit-answer" class="btn btn-success answer btn-lg btn-success"><span class="glyphicon glyphicon-ok"></span></div>
                <div id="next-question" class="btn btn-success answer btn-lg invisible"><span class="glyphicon glyphicon-ok"></span> Nächste Frage!</div>
            </div>
        </div>
    </div>

    <!-- Abort dialog -->
    <div id="abort-dialog" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="mySmallModalLabel" aria-hidden="true">
      <div class="modal-dialog modal-sm">
        <div class="modal-content">
          <div class="modal-header">
            <button type="button" class="close" data-dismiss="modal" aria-hidden="true">&times;</button>
            <h4 class="modal-title">Spiel beenden?</h4>
          </div>
          <div class="modal-body">
            Willst du wirklich das aktuelle Spiel abbrechen?
          </div>
          <div class="modal-footer">
            <a href="index.php" class="btn btn-default">Spiel beenden</a>
            <button type="button" class="btn btn-primary" data-dismiss="modal">Spiel fortsetzen</button>
          </div>
        </div>
      </div>
    </div>

    <div id="round-end-display" class="modal fade" data-backdrop="static" data-keyboard="false" tabindex="-1" role="dialog" aria-labelledby="mySmallModalLabel" aria-hidden="true">
      <div class="modal-dialog">
        <div class="modal-content">
          <div class="modal-header">
            <h4 class="modal-title">Du hast alle Fragen dieser Runde beantwortet!</h4>
          </div>
          <div class="modal-body">


            <div id="score"><h1>
            Gesamtpunkte: <span id="total-score"></span> von <span id="total-max-score">!</span>
            </h1></div>
          </div>
          <div class="modal-footer">
            <div id="next-round" class="btn btn-default">Neue Runde starten!</div>
          </div>
        </div>
      </div>
    </div>

    <script src="js/bootstrap.min.js"></script>
</body>

</html>
