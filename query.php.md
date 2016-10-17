# Query.php

This file is placed in the root directory of my *[OpenShift](openshift.redhat.com) [database server](http://database.roryclaasen.me)*. The reason for this is due to the lack of dart libraries that can deal with [sql](https://en.wikipedia.org/wiki/SQL) on a browser and not running from [dart vm](https://www.dartlang.org/dart-vm).

```php
<?php
header('Access-Control-Allow-Origin: *');
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
mysql_select_db($db_name) or die('{"error": "Could not select database"');
$sql =  $_GET['sql'];
$result = mysql_query($sql) or die('{"error": "Query failed: ' . mysql_error() . '"}');
echo '{"query": [';
$entry = False;
while ($line = mysql_fetch_array($result, MYSQL_ASSOC)) {
	if ($entry) echo ',';
	echo json_encode($line);
	$entry = True;
}
echo ']}';
mysql_free_result($result);
mysql_close($link);
?>
```
