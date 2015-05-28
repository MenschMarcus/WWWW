
<!DOCTYPE html>
<html lang="de">

<head>
  <meta charset="utf-8">
  <meta id="viewport" name="viewport" content="initial-scale=1, maximum-scale=1, user-scalable=no">

  <title>WWWW</title>
  <script type="text/javascript" src="script/third-party/jquery-1.10.2.js"></script>
  <script type="text/javascript" src="script/third-party/BrowserDetect.js"></script>

  <script type="text/javascript" src="build/BrowserDetector.js"></script>

  <link href='http://fonts.googleapis.com/css?family=Roboto:100,300,400' rel='stylesheet' type='text/css'>
  <link rel="stylesheet" type="text/css" href="style/style.css" />
  <link rel="stylesheet" type="text/css" href="style/feedback.css" />

  <script type="text/javascript">

    var mobile = false;

    if( /Android|webOS|iPhone|iPad|iPod|BlackBerry/i.test(navigator.userAgent) ) {
      var ww =$(window).width()
      var wh =$(window).height()
      var mw = 480; // min width of site
      var mh = 700; // min height of site
      var w_ratio =  ww / mw;
      var h_ratio =  wh / mh;

      var ratio = Math.min(w_ratio, h_ratio);

      $('#viewport').attr('content', 'initial-scale=' + ratio + ', maximum-scale=' + ratio + ', minimum-scale=' + ratio + ', user-scalable=no');
      mobile = true;
    }

    $(document).ready(function($) {
      $("#feedback-fail").hide()
      var browserDetector = new WWWW.BrowserDetector();
      var p = browserDetector.platform;

      if (mobile) {
        $("body").addClass("mobile");
      }

    });
  </script>
</head>
<body>
  <div class="phone-outer">
    <div class="phone-inner">
      <div class="text-center">
        <img id="logo" src="img/logo.svg" />
      </div>
      <div class="text-center">
        <p><a class="btn block" href="#"><img src="img/googleplus.svg"> <span>mit Google+ einloggen</span></a></p>
        <p><a class="btn block" href="#"><img src="img/facebook.svg"> <span>mit facebook einloggen</span></a></p>
        <br>
        <p><a class="btn block primary" href="question.php">Spiel starten</a></p>
      </div>
      <div id="histoglobe" class="text-center">
        <img src="img/histoglobe.png" />
      </div>
      <div id="feedback-fail" class="feedback-start-fail"> WWWW läuft leider noch nicht auf deiner Plattform! Probiere es an deinem Rechner.</div>
    </div>
  </div>
  <div id="link-imprint">
    <p>&copy; HistoGlobe GbR 2014 - 2015 - <a href="imprint.php">Impressum</a></p>
  </div>
</body>

</html>
