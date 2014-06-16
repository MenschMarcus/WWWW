<?php
/*
    EXAMPLE
    include "./database.php";
    $db = new database();

    if(isset($_GET["addFacebook"])) {
        $result = $db->query("UPDATE users SET facebook='".$_POST["fb_nickname"]."' WHERE id=".$_GET["user_id"].";", $db->getConnection());
        $_SESSION['facebook'] = $_POST["fb_nickname"];
        header('Location: index.php');
    }
*/
class database {

    private $connection;

    function __construct() {
        $link = mysql_connect('histoglobe.com', 'wwww', '1q2w3e4r.');
        if(mysql_select_db ("wwww", $link))
            $this->connection = $link;
        else
            $this->connection = false;
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
