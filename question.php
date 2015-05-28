<!DOCTYPE html>
<html lang="de">

<?php session_start(); ?>

<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=0">

  <script type="text/javascript" src="script/third-party/jquery-1.10.2.js"></script>
  <script type="text/javascript" src="script/third-party/jquery-ui-1.10.4.min.js"></script>
  <script type="text/javascript" src="script/third-party/raty/jquery.raty.js"></script>
  <script type="text/javascript" src="script/third-party/jquery.ui.touch-punch.min.js"></script>
  <script type="text/javascript" src="script/third-party/BrowserDetect.js"></script>
  <script type="text/javascript" src="script/third-party/leaflet.js"></script>


  <script src="https://apis.google.com/js/plusone.js"></script>

  <script type="text/javascript" src="build/executePHPFunction.js"></script>
  <script type="text/javascript" src="build/BrowserDetector.js"></script>
  <script type="text/javascript" src="build/highscores.js"></script>
  <script type="text/javascript" src="build/question.js"></script>
  <script type="text/javascript" src="build/marker.js"></script>
  <script type="text/javascript" src="build/feedback.js"></script>
  <script type="text/javascript" src="build/mobileKeyboardHandler.js"></script>

  <link rel="stylesheet" type="text/css" href="style/third_party/leaflet.css" />
  <link rel="stylesheet" type="text/css" href="script/third-party/raty/jquery.raty.css">
  <link rel="stylesheet" type="text/css" href="style/style.css" />
  <link rel="stylesheet" type="text/css" href="style/marker.css" />
  <link rel="stylesheet" type="text/css" href="style/feedback.css" />
  <link rel="stylesheet" type="text/css" href="style/highscores.css" />
  <link rel="stylesheet" type="text/css" href="style/zoom_control.css" />
  <link rel="stylesheet" type="text/css" href="style/pulse_dot.css" />

  <link href='http://fonts.googleapis.com/css?family=Roboto:100,300,400' rel='stylesheet' type='text/css'>
  <link href="font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css">

  <script type="text/javascript" src="http://w.sharethis.com/button/buttons.js"></script>
  <script type="text/javascript">stLight.options({publisher: "ur-14bc1105-dbac-3c4b-e2aa-609a8f8c9a5b", doNotHash: true, doNotCopy: true, hashAddressBar: false});</script>

  <script type="text/javascript">
    window.___gcfg = {lang: 'de'};
    $(document).ready(function($) {
      var mobileKeyboardHandler = new WWWW.MobileKeyboardHandler();
      var theapp = new WWWW.QuestionHandler();
      var feedback = new WWWW.FeedbackHandler();

      $('#question-progress').css({width:'100%'});

      // google+
      // (function() {
      //   var po = document.createElement('script'); po.type = 'text/javascript'; po.async = true;
      //   po.src = 'https://apis.google.com/js/platform.js';
      //   var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(po, s);
      // })();

      // twitter
      // !function(d,s,id){var js,fjs=d.getElementsByTagName(s)[0],p=/^http:/.test(d.location)?'http':'https';if(!d.getElementById(id)){js=d.createElement(s);js.id=id;js.src=p+'://platform.twitter.com/widgets.js';fjs.parentNode.insertBefore(js,fjs);}}(document, 'script', 'twitter-wjs');

      // facebook
      // (function(d, s, id) {
      //   var js, fjs = d.getElementsByTagName(s)[0];
      //   if (d.getElementById(id)) return;
      //   js = d.createElement(s); js.id = id;
      //   js.src = "//connect.facebook.net/de_DE/sdk.js#xfbml=1&version=v2.0";
      //   fjs.parentNode.insertBefore(js, fjs);
      // }(document, 'script', 'facebook-jssdk'));
    });
  </script>

</head>

<body>
    <div id="fb-root"></div>

    <div class="phone-outer">
      <div class="phone-inner">
        <div id="main-layout">
          <div class="layout-row shrink">
          <div class="question-bar">
            <div id="question-bar">
              <div id="question-number-container">
                <span class="text-left">Frage <span id="question-number">1</span></span>
                <span class="pull-right"><span id="question-author"></span></span>
              </div>
              <div id="question"></div>
              <div class="question-progress-background"></div>
              <div id="question-progress" class="question-progress animate"></div>

            </div>
          </div>
          </div><div class="layout-row">
          <div class="map-area">
            <div class="map" id="map"></div>
            <div id="map-marker-container">
              <div id="map-marker" class="pd-container">
                <div class="pd-pulse"></div>
                <div class="pd-dot"></div>
              </div>
            </div>
            <div id="map-zoom-control">
              <img id="map-zoom-plus" class="zoom-button" src="img/plus.svg"></img>
              <div id="map-zoom-slider">
                <div id="map-zoom-line"></div>
                <div id="map-zoom-handle-outer">
                  <div id="map-zoom-handle-inner"></div>
                </div>
              </div>
              <img id="map-zoom-minus" class="zoom-button" src="img/minus.svg"></img>
            </div>
            <div class="timeline" id="timeline">
              <div id="tl-year-container">
                <div id="tl-chosen" class="tl-year-box tl-year-box center">
                  <div id="tl-chosen-text" class="tl-year-box-text">gewähltes Jahr</div>
                  <div id="tl-chosen-year" class="tl-year-box-year">1900</div>
                </div>
                <div id="tl-correct" class="tl-year-box tl-year-box left">
                  <div id="tl-correct-text" class="tl-year-box-text">korrektes Jahr</div>
                  <div id="tl-correct-year" class="tl-year-box-year">1800</div>
                </div>
              </div>
              <div id="tl-zoom-control">
                <img id="tl-zoom-minus" class="zoom-button" src="img/minus.svg"></img>
                <div id="tl-zoom-slider">
                  <div id="tl-zoom-line"></div>
                  <div id="tl-zoom-handle-outer">
                    <div id="tl-zoom-handle-inner" class="pd-container">
                      <div class="pd-pulse"></div>
                      <div class="pd-dot"></div>
                    </div>
                  </div>
                </div>
                <img id="tl-zoom-plus" class="zoom-button" src="img/plus.svg"></img>
              </div>
            </div>
            <div id="abort"><img src="img/cross.svg" /></div>
            <div id="submit-answer-outer"><div id="submit-answer" class="link btn primary invisible"><img src="img/check.svg" /></div></div>
            <div id="round-end" class="link invisible"><i class="fa fa-check"></i> Runde beenden!</div>
            <div id="results" class="text-center">
              <div id="answer"><span id="answer-location"></span>, <span id="answer-year"></span></div>
              <div id="answer-info"></div>
              <div id="score">
                <div id="answer-total-score"></div>
                <div id="answer-total-score-label"></div>
                <div id="answer-error">Distanz: <span id="answer-spatial-distance"></span> / <span id="answer-temporal-distance"></span></div>
                <div id="next-question" class="link btn primary invisible"><img src="img/arrow-right.svg" /></div>
                <div id="abort2"><img src="img/cross.svg" /></div>
                <div id="next-round" class="link invisible"><i class="fa fa-check"></i> Neue Runde starten!</div>
              </div>
              <!-- <br/>
              Wie hat dir die Frage gefallen? <div id="rate-question"></div> -->
            </div>
          </div>
          </div>
        </div>
      </div>
    </div>

</body>

</html>
