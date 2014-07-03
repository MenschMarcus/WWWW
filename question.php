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
  <script src="http://cdn.leafletjs.com/leaflet-0.7.3/leaflet.js"></script>


  <script src="https://apis.google.com/js/plusone.js"></script>

  <script type="text/javascript" src="build/executePHPFunction.js"></script>
  <script type="text/javascript" src="build/BrowserDetector.js"></script>
  <script type="text/javascript" src="build/highscores.js"></script>
  <script type="text/javascript" src="build/question.js"></script>
  <script type="text/javascript" src="build/marker.js"></script>
  <script type="text/javascript" src="build/feedback.js"></script>
  <script type="text/javascript" src="build/mobileKeyboardHandler.js"></script>

  <link rel="stylesheet" href="http://cdn.leafletjs.com/leaflet-0.7.3/leaflet.css" />
  <link rel="stylesheet" type="text/css" href="style/third-party/bootstrap.css">
  <link rel="stylesheet" type="text/css" href="style/third-party/bootstrap-social.css">
  <link rel="stylesheet" type="text/css" href="style/third-party/bootstrap-theme.css">
  <link rel="stylesheet" type="text/css" href="script/third-party/raty/jquery.raty.css">
  <link rel="stylesheet" type="text/css" href="style/style.css" />
  <link rel="stylesheet" type="text/css" href="style/marker.css" />
  <link rel="stylesheet" type="text/css" href="style/feedback.css" />
  <link rel="stylesheet" type="text/css" href="style/highscores.css" />

  <link href="font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css">

  <script type="text/javascript" src="http://w.sharethis.com/button/buttons.js"></script>
  <script type="text/javascript">stLight.options({publisher: "ur-14bc1105-dbac-3c4b-e2aa-609a8f8c9a5b", doNotHash: true, doNotCopy: true, hashAddressBar: false});</script>

  <script type="text/javascript">
    window.___gcfg = {lang: 'de'};
    $(document).ready(function($) {
      var theapp = new WWWW.QuestionHandler();
      var feedback = new WWWW.FeedbackHandler();
      var mobileKeyboardHandler = new WWWW.MobileKeyboardHandler();

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
        <div class="map-area">
          <div class="map" id="map"></div>
        </div>
        <div class="timeline" id="timeline"></div>
        <div class="question-bar">
          <div id="hide-question-bar">
            <div id="hide-question-bar-inner">
              <i class="fa fa-arrows-v"></i>
            </div>
          </div>
          <div id="question-bar">
            <div id="question-number-container" class="text-center">Frage <span id="question-number">1</span>/<span id="questions-per-round">5</span>:</div>
            <div id="question"></div>
            <div id="results" class="text-center">
              <div id="score">
                <h1><span id="answer-total-score"></span></h1>
                <!-- <div>(<span id="answer-score"></span> + <span id="answer-time-bonus"></span>)</div> -->
                <div><span id="answer-location"></span>, <span id="answer-year"></span></div>
                <div>Distanz: <span id="answer-spatial-distance"></span> / <span id="answer-temporal-distance"></span></div>
              </div>
              <div id="answer-info"></div>
              <br/>
              Wie hat dir die Frage gefallen? <div id="rate-question"></div>
            </div>
          </div>

          <div id="round-end-display">

            <div id="score">
              <h1> Gesamtpunkte: <span id="total-score"></span> </h1>
            </div>

            <div class="social-buttons">
              <!-- <span class="fb-share-button" data-href="http://waswarwannwo.histoglobe.com/" data-type="button_count"></span>
              <span>
              <a href="https://twitter.com/share" class="twitter-share-button" data-url="http://waswarwannwo.histoglobe.com">Twittern</a>
              </span> -->
              <span st_url="http://waswarwannwo.histoglobe.com/" class='st_facebook_hcount' displayText='Facebook'></span>
              <span st_url="http://waswarwannwo.histoglobe.com/" class='st_twitter_hcount' displayText='Tweet'></span>
              <span st_url="http://waswarwannwo.histoglobe.com/" class='st_googleplus_hcount' displayText='Google +'></span>
            </div>

            <br>

            <div class="panel-group" id="accordion">
              <div class="panel panel-default">
                <div class="panel-heading" data-target="#collapseOne" data-toggle="collapse" data-parent="#accordion">
                  <div id="scroll-table-head" class="panel-title">
                    <a class="accordion-toggle">
                      <i class="fa fa-trophy"></i> Bestenliste
                    </a>
                  </div>
                </div>

                <div id="collapseOne" class="panel-collapse collapse">
                  <div id="hsc-scroll-table">
                    <table class="table table-striped">
                      <thead>
                        <tr>
                          <th>Rang</th>
                          <th>Name</th>
                          <th>Score</th>
                        </tr>
                      </thead>
                      <tbody id="highscore-list"> </tbody>
                    </table>
                  </div>
                </div>
              </div>

              <div class="panel panel-default">
                <div class="panel-heading" data-target="#collapseTwo" data-toggle="collapse" data-parent="#accordion">
                  <div class="panel-title">
                    <a class="accordion-toggle">
                      <i class="fa fa-pencil"></i> Neue Frage einreichen
                    </a>
                  </div>
                </div>

                <div id="collapseTwo" class="panel-collapse collapse">
                  <div class="panel-body">
                    <div id="user-question-group" style="margin-bottom:15px;">
                      <textarea id="user-question" name="user-question" placeholder="Gib hier deine Frage ein!" class="form-control" rows="3"></textarea>
                    </div>
                    <div class="row">
                      <div class="col-xs-6">
                        <!-- <div id="user-question-location-group" class="form-group floating-label-form-group">
                          <input id="user-question-location" class="form-control" type="text" name="user-question-location" placeholder="Antwort Ort">
                        </div> -->
                        <div id="user-question-name-group" class="form-group floating-label-form-group">
                          <input id="user-question-name" class="form-control" type="text" name="user-question-name" placeholder="Dein Name">
                        </div>
                      </div>
                      <!-- <div class="col-xs-6">
                        <div id="user-question-year-group" class="form-group floating-label-form-group">
                          <input id="user-question-year" class="form-control" type="text" name="user-question-year" placeholder="Antwort Jahr">
                        </div>
                        <div id="user-question-email-group" class="form-group floating-label-form-group">
                          <input id="user-question-email" class="form-control" type="text" name="user-question-email" placeholder="Deine Email-Adresse">
                        </div>
                      </div> -->
                    </div>

                    <div id="user-question-answer" class="feedback-answer"> Vielen Dank für deine Frage!</div>
                    <p>
                      <button id="submit-user-question" type="submit_button" class="btn btn-success">Frage absenden!</button>
                    </p>
                  </div>
                </div>
              </div>


              <div class="panel panel-default">
                <div class="panel-heading" data-target="#collapseThree" data-toggle="collapse" data-parent="#accordion">
                  <div class="panel-title">
                    <a class="accordion-toggle">
                      <i class="fa fa-comments"></i> Feedback
                    </a>
                  </div>
                </div>

                <div id="collapseThree" class="panel-collapse collapse">
                  <div id="contact_form" class="panel-body">
                    <p>
                    <textarea id="feedback-message" name="message" placeholder="Schreib uns hier deine Meinung, Anregungen oder Kritik!" class="form-control" rows="3"></textarea>
                    </p>
                    <div id="feedback-answer" class="feedback-answer"> Vielen Dank für dein Feedback!</div>
                    <p>
                    <button id="submit-feedback" type="submit_button" class="btn btn-success">Nachricht absenden!</button>
                    </p>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </div>
        <div class="control-bar">
            <div id="question-progress" class="question-progress animate"></div>
            <div id="count-down" class="count-down"></div>
            <button type="button" data-toggle="modal" data-target="#abort-dialog" class="btn btn-danger abort btn-lg"><span class="glyphicon glyphicon-remove"></span></button>
            <div id="submit-answer" class="btn btn-success answer btn-lg btn-success"><span class="glyphicon glyphicon-ok"></span></div>
            <div id="next-question" class="btn btn-success answer btn-lg invisible"><span class="glyphicon glyphicon-ok"></span> Nächste Frage!</div>
            <div id="round-end" class="btn btn-success answer btn-lg invisible"><span class="glyphicon glyphicon-ok"></span> Runde beenden!</div>
            <div id="next-round" class="btn btn-success answer btn-lg invisible"><span class="glyphicon glyphicon-ok"></span> Neue Runde starten!</div>
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
            <a href="index.php" class="btn btn-danger">Spiel beenden</a>
            <button type="button" class="btn btn-success" data-dismiss="modal">Spiel fortsetzen</button>
          </div>
        </div>
      </div>
    </div>

    <div id="name-email-display" >
      <div id="name-group" class="form-group col-xs-12 floating-label-form-group">
        <label class="control-label" for="name">Name</label>
        <input id="name" class="form-control" type="text" name="name" placeholder="Name">
      </div>
        <br/>
      <div  id="email-group" class="form-group col-xs-12 floating-label-form-group">
        <label class="control-label" for="email">Email-Adresse (bleibt geheim)</label>
        <input id="email" class="form-control" type="text" name="email" placeholder="Email-Adresse">
      </div>
        <br/>
        <button id="submit-name-email" type="submit_button" class="btn btn-success">Los!</button>
      </div>
    </div>

    <script src="script/third-party/bootstrap.min.js"></script>
</body>

</html>
