
<!DOCTYPE html>
<html lang="de">

<head>
  <meta charset="utf-8">
  <title>WWWW</title>
  <script type="text/javascript" src="script/third-party/jquery-1.10.2.js"></script>
  <script type="text/javascript" src="script/third-party/BrowserDetect.js"></script>

  <script type="text/javascript" src="build/BrowserDetector.js"></script>

  <link rel="stylesheet" type="text/css" href="style/bootstrap.css">
  <link rel="stylesheet" type="text/css" href="style/bootstrap-theme.css">
  <link rel="stylesheet" type="text/css" href="style/style.css" />
  <link rel="stylesheet" type="text/css" href="style/feedback.css" />

  <script type="text/javascript">
    $(document).ready(function($) {
      $("#feedback-fail").hide()
      var browserDetector = new WWWW.BrowserDetector();
      var p = browserDetector.platform;

      if (p=="Android" || p=="iPhone" || p=="iPad" || p=="unknown") {
        $("#start-button").hide()
        $("#instructions").hide()
        $("#feedback-fail").hide().slideDown()
      }
    });
  </script>
</head>
<body>
  <div class="phone-outer">
    <div class="phone-inner title-image">
      <div id="instructions">
        <p class="text-center" style="margin-top:300px"><img src="img/marker_map.png" /></p>
        <h3 class="text-center well">Platziere beide Marker an die richtigen Stellen auf der Zeitleiste und der Karte!</h3>
      </div>
      <div id="feedback-fail" class="feedback-start-fail"> WWWW läuft leider noch nicht auf deiner Plattform! Probiere es an deinem Rechner.</div>
      <div id="start-button" class="well start">
        <a href="question.php" type="button" class="btn btn-success btn-lg btn-block">Spiel starten!</a>
      </div>
    </div>
  </div>

  <script src="js/bootstrap.min.js"></script>
</body>

</html>
