
<!DOCTYPE html>
<html lang="de">

<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=0">

  <title>WWWW</title>
  <script type="text/javascript" src="script/third-party/jquery-1.10.2.js"></script>
  <script type="text/javascript" src="script/third-party/BrowserDetect.js"></script>

  <script type="text/javascript" src="build/BrowserDetector.js"></script>

  <link rel="stylesheet" type="text/css" href="style/third-party/bootstrap.min.css">
  <link rel="stylesheet" type="text/css" href="style/third-party/site.min.css">
  <link rel="stylesheet" type="text/css" href="style/third-party/bootflat.min.css">
  <link rel="stylesheet" type="text/css" href="style/style.css" />
  <link rel="stylesheet" type="text/css" href="style/feedback.css" />

  <script type="text/javascript">
    $(document).ready(function($) {
      $("#feedback-fail").hide()
      var browserDetector = new WWWW.BrowserDetector();
      var p = browserDetector.platform;

      // if (p=="Android" || p=="iPhone" || p=="iPad" || p=="iPhone/iPod" || p=="unknown") {
      //   $("#instructions").hide()
      //   $("#feedback-fail").hide().slideDown()
      // }
    });
  </script>
</head>
<body>
  <div class="phone-outer">
    <div class="phone-inner">
      <div id="instructions">
        <p class="text-center" style="margin-top:10%"><img src="img/marker_map.png" /></p>
        <div class="text-center" style="padding:10px;" >
          <h3>Platziere beide Marker an die richtigen Stellen auf der Zeitleiste und der Karte!</h3>
          <p><a href="question.php" type="button" style="padding:30px 10px;" class="btn btn-success btn-lg btn-block">Spiel starten!</a></p>
        </div>
      </div>
      <div id="feedback-fail" class="feedback-start-fail"> WWWW läuft leider noch nicht auf deiner Plattform! Probiere es an deinem Rechner.</div>
      <div id="link-imprint">
        <p>&copy; HistoGlobe GbR 2014 - <a href="imprint.php">Impressum</a></p>
      </div>
    </div>
  </div>

  <script src="script/third-party/bootstrap.min.js"></script>
</body>

</html>
