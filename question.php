<!DOCTYPE html>
<html lang="de">

<head>
  <script type="text/javascript" src="script/jquery-1.9.0.min.js"></script>
  <script type="text/javascript" src="build/question.js"></script>

  <script type="text/javascript" src="script/jquery-1.9.0.min.js"></script>
  <link rel="stylesheet" type="text/css" href="style/bootstrap.css">
  <link rel="stylesheet" type="text/css" href="style/bootstrap-theme.css">
  <link rel="stylesheet" type="text/css" href="style/style.css" />

  <script type="text/javascript">
    $(document).ready(function($) {
      var theapp = new WWWW.QuestionHandler();
    });
  </script>
</head>

<body>

    <div class="phone-outer">
        <div class="phone-inner">
            <div class="start">
                <a href="index.php">BEENDEN!</a>
            </div>
            <div class="map"></div>
            <div class="question-bar">
                Wann war eigentlich was wo?
            </div>
            <div class="control-bar">
                <div class="btn btn-danger btn-lg"><span class="glyphicon glyphicon-remove"></span></div>
                <div class="btn btn-success btn-lg pull-right"><span class="glyphicon glyphicon-ok"></span></div>
                <div class="progress progress-striped active">
                    <div class="progress-bar" role="progressbar" aria-valuenow="45" aria-valuemin="0" aria-valuemax="100" style="width: 45%"></div>
                </div>
            </div>
        </div>
    </div>

    <script src="js/bootstrap.min.js"></script>
</body>

</html>
