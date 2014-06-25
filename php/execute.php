<?php

session_start();

include "database.php";
$db = new database();

if(isset($_GET["getQuestions"])) {
  $str_json = file_get_contents('php://input');
  $input = json_decode($str_json);
  $funny =  $input->funny;
  $result = $db->query("SELECT * FROM `question` WHERE `funny`={$funny};");
  $rows = array();
  while($row = mysql_fetch_assoc($result)) {
    $rows[] = $row;
  }
  print json_encode($rows);
}

if(isset($_GET["getMaps"])) {
  $result = $db->query("SELECT * FROM `map`;");
  $rows = array();
  while($row = mysql_fetch_assoc($result)) {
     $rows[] = $row;
   }
  print json_encode($rows);
}

if(isset($_GET["getTimelines"])) {
  $result = $db->query("SELECT * FROM `timeline`;");
  $rows = array();
  while($row = mysql_fetch_assoc($result)) {
     $rows[] = $row;
   }
  print json_encode($rows);
}

if(isset($_GET["insertIntoDB"])) {
  $str_json = file_get_contents('php://input');
  $input = json_decode($str_json);
  $table = $input->table;
  $names =  $input->names;
  $values = $input->values;
  $result = $db->query("INSERT INTO {$table} ({$names}) VALUES ({$values});");
  echo $result;
}

if(isset($_GET["userIsFunny"])) {
  $str_json = file_get_contents('php://input');
  $input = json_decode($str_json);
  $session_id = $input->session_id;
  $result = $db->query("SELECT `funny` FROM user WHERE `session_id` = '{$session_id}';");
  $rows = array();
  if($result) {
    while($row = mysql_fetch_assoc($result)) {
      $rows[] = $row;
    }
  }
  print json_encode($rows);
}

if(isset($_GET["getSessionID"])) {
  $s_id = session_id();
  echo $s_id;
}

if(isset($_GET["manualSQLQuery"])) {
  $str_json = file_get_contents('php://input');
  $input = json_decode($str_json);
  $result = $db->query($input->query);
  $rows = array();
  while($row = mysql_fetch_assoc($result)) {
     $rows[] = $row;
   }
  print json_encode($rows);
}
/*
if(isset($_GET["getScoreList"])) {
  $result = $db->query("SELECT `nickname`, `score` FROM score  ORDER BY `score`;");
  $rows = array();
  while($row = mysql_fetch_assoc($result)) {
    $rows[] = $row;
  }
  print json_encode($rows);
}
*/

?>
