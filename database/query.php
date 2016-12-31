<?php
/*
Copyright 2016-2017 Rory Claasen

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
*/
$access = array("http://www.roryclaasen.me", "http://roryclaasen.me", "http://127.0.0.1:3694");
$orign = $_SERVER['HTTP_ORIGIN'];
if (in_array($orign, $access)) {
   header('Access-Control-Allow-Origin: ' . $orign);
   header('Access-Control-Allow-Methods: POST');

   $post = json_decode(file_get_contents('php://input'));

   if (!empty($post)) {
      header('Content-Type: application/json');

      define('DB_HOST', getenv('OPENSHIFT_MYSQL_DB_HOST'));
      define('DB_PORT', getenv('OPENSHIFT_MYSQL_DB_PORT'));
      define('DB_USER', getenv('OPENSHIFT_MYSQL_DB_USERNAME'));
      define('DB_PASS', getenv('OPENSHIFT_MYSQL_DB_PASSWORD'));
      define('DB_NAME', getenv('OPENSHIFT_GEAR_NAME'));
      $dbhost = constant("DB_HOST");
      $dbport = constant("DB_PORT");
      $dbusername = constant("DB_USER");
      $dbpassword = constant("DB_PASS");
      $db_name = constant("DB_NAME");

      $link = mysql_connect($dbhost, $dbusername, $dbpassword)  or die('{"error": "Could not connect: " '. mysql_error(). '"}');

      mysql_select_db($db_name) or die('{"error": "Could not select database"}');

      $result = mysql_query($post->query) or die('{"error": "Query failed: ' . mysql_error() . '"}');

      $output = '{"output": [';
      $entry = False;
      while ($line = mysql_fetch_array($result, MYSQL_ASSOC)) {
         if ($entry) $output .= ',';
         $output .= json_encode($line);
         $entry = True;
      }
      $output .= ']}';

      mysql_free_result($result);
      mysql_close($link);

      echo $output;
   } else {
      header('HTTP/1.0 403 Forbidden');
   }
} else{
   header('HTTP/1.0 403 Forbidden');
}
?>
