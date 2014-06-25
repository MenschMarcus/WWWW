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
          $("#round-count-funny").html((sum/len).toFixed(3));
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
          $("#round-count-normal").html((sum/len).toFixed(3));
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
          var average = timesum/len;
          $("#time-per-question").html((average / 1000).toFixed(3));

          var squared_diff_sum = 0;
          for (i=0; i<len; i++) {
            squared_diff_sum += Math.pow(parseInt(obj[i].end_time) - parseInt(obj[i].start_time) - average, 2);
          }

          var standardDev = Math.sqrt(squared_diff_sum/len);
          $("#time-per-question-standard-deviation").html((standardDev / 1000).toFixed(3));
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
          var average = timesum/len;
          $("#time-per-question-funny").html((average / 1000).toFixed(3));

          var squared_diff_sum = 0;
          for (i=0; i<len; i++) {
            squared_diff_sum += Math.pow(parseInt(obj[i].end_time) - parseInt(obj[i].start_time) - average, 2);
          }

          var standardDev = Math.sqrt(squared_diff_sum/len);
          $("#time-per-question-standard-deviation-funny").html((standardDev / 1000).toFixed(3));
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
          var average = timesum/len;
          $("#time-per-question-normal").html((average / 1000).toFixed(3));

          var squared_diff_sum = 0;
          for (i=0; i<len; i++) {
            squared_diff_sum += Math.pow(parseInt(obj[i].end_time) - parseInt(obj[i].start_time) - average, 2);
          }

          var standardDev = Math.sqrt(squared_diff_sum/len);
          $("#time-per-question-standard-deviation-normal").html((standardDev / 1000).toFixed(3));
        }
      );

      var send9 = {
        query: "SELECT COUNT(DISTINCT `session_id`) FROM answer WHERE `platform`='Windows';"
      };

      WWWW.executePHPFunction("manualSQLQuery", send9,
        function(response) {
          var obj = JSON.parse(response);
          $("#user-count-windows").html(obj[0]["COUNT(DISTINCT `session_id`)"]);
        }
      );

      var send9 = {
        query: "SELECT COUNT(DISTINCT `session_id`) FROM answer WHERE `platform`='Linux';"
      };

      WWWW.executePHPFunction("manualSQLQuery", send9,
        function(response) {
          var obj = JSON.parse(response);
          $("#user-count-linux").html(obj[0]["COUNT(DISTINCT `session_id`)"]);
        }
      );

      var send10 = {
        query: "SELECT COUNT(`q_id`), `session_id` FROM answer GROUP BY session_id;"
      };

      WWWW.executePHPFunction("manualSQLQuery", send10,
        function(response) {
          var obj = JSON.parse(response);
          var len = obj.length;
          var sum = 0;
          var numberOfElements = 0;
          for (i=0; i<len; i++) {
            var count = parseInt(obj[i]["COUNT(`q_id`)"]);

            if (count >= 5) {
              sum += count;
              numberOfElements += 1;
            }
          }

          var average = sum/numberOfElements;
          $("#average-questions").html(average.toFixed(3));

          var squared_diff_sum = 0;
          for (i=0; i<len; i++) {
            var count = parseInt(obj[i]["COUNT(`q_id`)"]);

              if (count >= 5) {
                squared_diff_sum += Math.pow(count - average, 2);
              }
          }

          var standardDev = Math.sqrt(squared_diff_sum/len);
          $("#question-standard-deviation").html(standardDev.toFixed(3));
        }
      );

      var send11 = {
        query: "SELECT COUNT(`q_id`) FROM answer WHERE `funny`=1 GROUP BY session_id;"
      };

      WWWW.executePHPFunction("manualSQLQuery", send11,
       function(response) {
          var obj = JSON.parse(response);
          var len = obj.length;
          var sum = 0;
          var numberOfElements = 0;
          for (i=0; i<len; i++) {
            var count = parseInt(obj[i]["COUNT(`q_id`)"]);

            if (count >= 5) {
              sum += count;
              numberOfElements += 1;
            }
          }

          var average = sum/numberOfElements;
          $("#average-questions-funny").html(average.toFixed(3));

          var squared_diff_sum = 0;
          for (i=0; i<len; i++) {
            var count = parseInt(obj[i]["COUNT(`q_id`)"]);

              if (count >= 5) {
                squared_diff_sum += Math.pow(count - average, 2);
              }
          }

          var standardDev = Math.sqrt(squared_diff_sum/len);
          $("#question-standard-deviation-funny").html(standardDev.toFixed(3));
        }
      );

      var send11 = {
        query: "SELECT COUNT(`q_id`) FROM answer WHERE `funny`!=1 GROUP BY session_id;"
      };

      WWWW.executePHPFunction("manualSQLQuery", send11,
        function(response) {
          var obj = JSON.parse(response);
          var len = obj.length;
          var sum = 0;
          var numberOfElements = 0;
          for (i=0; i<len; i++) {
            var count = parseInt(obj[i]["COUNT(`q_id`)"]);

            if (count >= 5) {
              sum += count;
              numberOfElements += 1;
            }
          }

          var average = sum/numberOfElements;
          $("#average-questions-normal").html(average.toFixed(3));

          var squared_diff_sum = 0;
          for (i=0; i<len; i++) {
            var count = parseInt(obj[i]["COUNT(`q_id`)"]);

              if (count >= 5) {
                squared_diff_sum += Math.pow(count - average, 2);
              }
          }

          var standardDev = Math.sqrt(squared_diff_sum/len);
          $("#question-standard-deviation-normal").html(standardDev.toFixed(3));
        }
      );


    });
  </script>
</head>

<body>
  <div class="stat-group">
    <div class="stat-row">
      <h3>Allgemein</h3>
    </div>
    <div class="stat-row stat-row-grey ">
      Anzahl verschiedener Spieler: <span id="user-count" class="stat-col-right"></span>
    </div>

    <div class="stat-row ">
      Durchschnittliche Anzahl gespielter Fragen (bei mind. 5): <span id="average-questions" class="stat-col-right"></span>
    </div>

    <div class="stat-row stat-row-grey ">
      Standardabweichung gespielter Fragen (bei mind. 5): <span id="question-standard-deviation" class="stat-col-right"></span>
    </div>

    <div class="stat-row ">
      Durchschnittliche Zeit pro Frage (in s): <span id="time-per-question" class="stat-col-right"></span>
    </div>

    <div class="stat-row stat-row-grey">
      Standardabweichung der Zeit pro Frage (in s): <span id="time-per-question-standard-deviation" class="stat-col-right"></span>
    </div>

    <div class="stat-row ">
      Anzahl der Nutzer mit Windows: <span id="user-count-windows" class="stat-col-right"></span>
    </div>

    <div class="stat-row stat-row-grey">
      Anzahl der Nutzer mit Linux: <span id="user-count-linux" class="stat-col-right"></span>
    </div>
  </div>


  <div class="stat-group">
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
      Durchschnittliche Anzahl gespielter Fragen: <span id="average-questions-funny" class="stat-col-right"></span>
    </div>

    <div class="stat-row">
      Standardabweichung gespielter Fragen: <span id="question-standard-deviation-funny" class="stat-col-right"></span>
    </div>

    <div class="stat-row stat-row-grey">
      Durchschnittliche Zeit pro Frage (in s): <span id="time-per-question-funny" class="stat-col-right"></span>
    </div>

    <div class="stat-row">
      Standardabweichung der Zeit pro Frage (in s): <span id="time-per-question-standard-deviation-funny" class="stat-col-right"></span>
    </div>
  </div>

  <div class="stat-group">
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
      Durchschnittliche Anzahl gespielter Fragen: <span id="average-questions-normal" class="stat-col-right"></span>
    </div>

    <div class="stat-row">
      Standardabweichung gespielter Fragen: <span id="question-standard-deviation-normal" class="stat-col-right"></span>
    </div>

    <div class="stat-row stat-row-grey">
      Durchschnittliche Zeit pro Frage (in s): <span id="time-per-question-normal" class="stat-col-right"></span>
    </div>

    <div class="stat-row">
      Standardabweichung der Zeit pro Frage (in s): <span id="time-per-question-standard-deviation-normal" class="stat-col-right"></span>
    </div>
  </div>

    <script src="js/bootstrap.min.js"></script>
</body>

</html>
