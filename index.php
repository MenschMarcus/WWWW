<?php
    session_start();
    include "./php/database.php";
    class WWWW {
        private $db;
        public $session_id;
        function __construct() {
            $this->db = new database();
        }
        public function getDB() {
            return $this->db;
        }
    }
    $wwww = new WWWW();
?>
<!DOCTYPE html>
<html lang="de">

<head>
    <title>WWWW</title>
    <script type="text/javascript" src="includes/jquery.js"></script>
    <script type="text/javascript" src="question.js"></script>
    <script type="text/javascript">
        $(document).ready(function($) {
            var theapp = new WWWW.QuestionHandler();
        });
    </script>
</head>
<body>
    <div>
    </div>
</body>

</html>
