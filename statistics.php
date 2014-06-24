<!DOCTYPE html>
<html lang="de">

<?php session_start(); ?>

<head>
  <meta charset="utf-8">

  <script type="text/javascript" src="script/third-party/jquery-1.10.2.js"></script>
  <script type="text/javascript" src="script/third-party/jquery-ui-1.10.4.min.js"></script>
  <script type="text/javascript" src="script/third-party/BrowserDetect.js"></script>

  <script type="text/javascript" src="build/BrowserDetector.js"></script>
  <script type="text/javascript" src="build/executePHPFunction.js"></script>

  <link rel="stylesheet" type="text/css" href="style/bootstrap.css">
  <link rel="stylesheet" type="text/css" href="style/bootstrap-theme.css">
  <link rel="stylesheet" type="text/css" href="style/bootstrap-social.css">
  <link rel="stylesheet" type="text/css" href="style/style.css" />
  <link rel="stylesheet" type="text/css" href="style/feedback.css" />
  <link rel="stylesheet" type="text/css" href="style/statistics.css" />

  <link href="font-awesome/css/font-awesome.min.css" rel="stylesheet" type="text/css">

  <script type="text/javascript">
    $(document).ready(function($) {
      var send1 = {
        query: "SELECT COUNT(DISTINCT `session_id`) FROM answer;"
      };

      WWWW.executePHPFunction("manualSQLQuery", send1,
        function(response) {
          var obj = JSON.parse(response);
          $("#user-count").html(obj[0]["COUNT(DISTINCT `session_id`)"]);
        }
      );

      var send2 = {
        query: "SELECT COUNT(DISTINCT `session_id`) FROM answer WHERE `funny`=1;"
      };

      WWWW.executePHPFunction("manualSQLQuery", send2,
        function(response) {
          var obj = JSON.parse(response);
          $("#user-count-funny").html(obj[0]["COUNT(DISTINCT `session_id`)"]);
        }
      );

      var send3 = {
        query: "SELECT COUNT(DISTINCT `session_id`) FROM answer WHERE `funny`!=1;"
      };

      WWWW.executePHPFunction("manualSQLQuery", send3,
        function(response) {
          var obj = JSON.parse(response);
          $("#user-count-normal").html(obj[0]["COUNT(DISTINCT `session_id`)"]);
        }
      );

      var send4 = {
        query: "SELECT Max(`round_count`) `round_count` FROM answer WHERE `funny`=1 GROUP BY session_id;"
      };

      WWWW.executePHPFunction("manualSQLQuery", send4,
        function(response) {
          var obj = JSON.parse(response);
          var len = obj.length;
          var sum = 0;
          for (i=0; i<len; i++) {
            sum += parseInt(obj[i].round_count);
          }
          $("#round-count-funny").html(sum/len);
        }
      );

      var send5 = {
        query: "SELECT Max(`round_count`) `round_count` FROM answer WHERE `funny`!=1 GROUP BY session_id;"
      };

      WWWW.executePHPFunction("manualSQLQuery", send5,
        function(response) {
          var obj = JSON.parse(response);
          var len = obj.length;
          var sum = 0;
          for (i=0; i<len; i++) {
            sum += parseInt(obj[i].round_count);
          }
          $("#round-count-normal").html(sum/len);
        }
      );

      var send6 = {
        query: "SELECT `start_time`, `end_time` FROM answer;"
      };

      WWWW.executePHPFunction("manualSQLQuery", send6,
        function(response) {
          var obj = JSON.parse(response);
          var len = obj.length;
          var timesum = 0;
          for (i=0; i<len; i++) {
            timesum += parseInt(obj[i].end_time) - parseInt(obj[i].start_time);
          }
          var average = (timesum/len) / 1000;
          $("#time-per-question").html(average);
        }
      );

      var send7 = {
        query: "SELECT `start_time`, `end_time` FROM answer WHERE `funny`=1;"
      };

      WWWW.executePHPFunction("manualSQLQuery", send7,
        function(response) {
          var obj = JSON.parse(response);
          var len = obj.length;
          var timesum = 0;
          for (i=0; i<len; i++) {
            timesum += parseInt(obj[i].end_time) - parseInt(obj[i].start_time);
          }
          var average = (timesum/len) / 1000;
          $("#time-per-question-funny").html(average);
        }
      );

      var send8 = {
        query: "SELECT `start_time`, `end_time` FROM answer WHERE `funny`!=1;"
      };

      WWWW.executePHPFunction("manualSQLQuery", send8,
        function(response) {
          var obj = JSON.parse(response);
          var len = obj.length;
          var timesum = 0;
          for (i=0; i<len; i++) {
            timesum += parseInt(obj[i].end_time) - parseInt(obj[i].start_time);
          }
          var average = (timesum/len) / 1000;
          $("#time-per-question-normal").html(average);
        }
      );


    });
  </script>
</head>

<body>
  <div class="stat">
    <div class="stat-row">
      <h3>Allgemein</h3>
    </div>
    <div class="stat-row stat-row-grey ">
      Anzahl verschiedener Spieler: <span id="user-count" class="stat-col-right"></span>
    </div>

    <div class="stat-row ">
      Durchschnittliche Zeit pro Frage (in s): <span id="time-per-question" class="stat-col-right"></span>
    </div>



    <div class="stat-row">
      <h3>Kuriose Fragen</h3>
    </div>

    <div class="stat-row stat-row-grey">
      Gemachte Spiele: <span id="user-count-funny" class="stat-col-right"></span>
    </div>

    <div class="stat-row">
      Durchschnittlich erreichte Runde: <span id="round-count-funny" class="stat-col-right"></span>
    </div>

    <div class="stat-row stat-row-grey">
      Durchschnittliche Zeit pro Frage (in s): <span id="time-per-question-funny" class="stat-col-right"></span>
    </div>



    <div class="stat-row">
      <h3>Normale Fragen</h3>
    </div>

    <div class="stat-row stat-row-grey">
      Gemachte Spiele: <span id="user-count-normal" class="stat-col-right"></span>
    </div>

    <div class="stat-row">
      Durchschnittlich erreichte Runde: <span id="round-count-normal" class="stat-col-right"></span>
    </div>

    <div class="stat-row stat-row-grey">
      Durchschnittliche Zeit pro Frage (in s): <span id="time-per-question-normal" class="stat-col-right"></span>
    </div>

  </div>
    <script src="js/bootstrap.min.js"></script>
</body>

</html>
