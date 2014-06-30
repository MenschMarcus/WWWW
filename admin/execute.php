<?php

include "../php/database.php";
$db = new database();

if(isset($_GET["insertIntoDB"])) {
  $str_json = file_get_contents('php://input');
  $input = json_decode($str_json);
  $table = $input->table;
  $names =  $input->names;
  $values = $input->values;
  $result = $db->query("INSERT INTO {$table} ({$names}) VALUES ({$values});");
  echo $result;
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


?>
