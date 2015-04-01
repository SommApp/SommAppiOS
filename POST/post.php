<?php
	header('Content-type: application/json');
	$myFile = "test.txt";
	$fh = fopen($myFile, 'a') or die("can't open file");


	
	if($_POST) {
		$time   = $_POST['time'];
		$email = $_POST['email'];
		$coords = $_POST['coords'];

		$stringData = "Time: ". $time ."\nEmail: " . $email. "\n Coords". $coords;
		fwrite($fh, $stringData);

		echo "YES";
	}
	fclose($fh);

?>
