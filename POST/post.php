<?php
	header('Content-type: application/json');
	$myFile = "test.txt";
	$fh = fopen($myFile, 'a') or die("can't open file");


	
	if($_POST) {
		$gps   = $_POST['gps'];
		$email = $_POST['email'];

		$stringData = $gps . $email;
		fwrite($fh, $stringData);

		echo "YES";
	}
	fclose($fh);

?>
