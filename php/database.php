<?php

class database {

  private $connection;

  function __construct() {
    //$mysqli = new mysqli('lvps5-35-242-120.dedicated.hosteurope.de:3306', 'wwww', '1q2w3e4r.', 'wwww');
     $link = mysql_connect('lvps5-35-242-120.dedicated.hosteurope.de:3306', 'wwww', '1q2w3e4r.');
     if(mysql_select_db ("wwww", $link)) {
       $this->connection = $link;
     } else {
       $this->connection = false;
     }
    if (!$link) {
     die('Verbindung zur Datenbank schlug fehl: ' . mysql_error());
    }
  }

  public function close() {
    if($this->connection != false)
      mysql_close($this->connection);
  }

  public function query($string) {
    $result = mysql_query($string);
    if(!$result) {
      print "".mysql_error();
    } else {
      return $result;
    }
  }

  public function getConnection() {
    return $this->connection;
  }
}
?>
