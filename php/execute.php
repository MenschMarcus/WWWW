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


?>
