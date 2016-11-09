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

$post = json_decode(file_get_contents('php://input'));
if (!empty($post)) {
	$query = $post->query;

	$link = mysql_connect($dbhost, $dbusername, $dbpassword)  or die('{"error": "Could not connect: " '. mysql_error(). '"}');

	mysql_select_db($db_name) or die('{"error": "Could not select database"');

	$result = mysql_query($query) or die('{"error": "Query failed: ' . mysql_error() . '"}');
	echo '{"output": [';
	$entry = False;
	while ($line = mysql_fetch_array($result, MYSQL_ASSOC)) {
		if ($entry) echo ',';
		echo json_encode($line);
		$entry = True;
	}
	echo ']}';

	mysql_free_result($result);
	mysql_close($link);
}
?>
