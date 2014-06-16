<!DOCTYPE html>
<html lang="de">

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

      $('#progress-bar').css({width:'100%'});

      setTimeout(function() {
        $('#timeout-dialog').modal('show');
      }, 20000);

    });
  </script>
</head>

<body>
    <div class="phone-outer">
        <div class="phone-inner">
            <div class="timeline"></div>
            <div class="map" id="map"></div>
            <div class="question-bar">
                Wann und wo hat Felix zum ersten mal gekackt?
            </div>
            <div class="control-bar">
                <button type="button" data-toggle="modal" data-target="#abort-dialog" class="btn btn-danger btn-lg"><span class="glyphicon glyphicon-remove"></span></button>
                <a href="question.php" class="btn btn-success btn-lg pull-right"><span class="glyphicon glyphicon-ok"></span></a>
                <div class="progress progress-striped active">
                    <div id="progress-bar" class="progress-bar" role="progressbar" aria-valuenow="45" aria-valuemin="0" aria-valuemax="100" style="width: 0%"></div>
                </div>
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

    <!-- Time out dialog -->
    <div id="timeout-dialog" class="modal fade" tabindex="-1" role="dialog" aria-labelledby="mySmallModalLabel" aria-hidden="true">
      <div class="modal-dialog modal-sm">
        <div class="modal-content">
          <div class="modal-header">
            <h4 class="modal-title">Zeit abgelaufen!</h4>
          </div>
          <div class="modal-body">
            Du warst leider zu langsam!
          </div>
          <div class="modal-footer">
            <a href="question.php" class="btn btn-default">Nächste Frage!</a>
          </div>
        </div>
      </div>
    </div>

    <script src="js/bootstrap.min.js"></script>
</body>

</html>
