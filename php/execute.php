<?php

include "database.php";
$db = new database();

if(isset($_GET["getQuestions"])) {
  $result = $db->query("SELECT * FROM `question`;");
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

// if(isset($_GET["insertIntoDB"])) {
//     $str_json = file_get_contents('php://input');
//     $input = json_decode($str_json);
//     $table = $input->table
//     $names =  $input->names;
//     $values = $input->values;
//     $result = $db->query("INSERT INTO {$table} ({$names}) VALUES ({$values});");
//     echo $result;
// }

?>
