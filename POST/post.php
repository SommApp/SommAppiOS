<?php
	header('Content-type: application/json');
	$myFile = "test.txt";
	$fh = fopen($myFile, 'w') or die("can't open file");
	$stringData = "Bobby Bopper\n";
	fwrite($fh, $stringData);
	$stringData = "Tracy Tanner\n";
	fwrite($fh, $stringData);

	
	if($_POST) {
		$gps   = $_POST['gps'];
		$email = $_POST['email'];

		$stringData = $gps . $email;
		fwrite($fh, $stringData);

		echo "YES";
	}
	fclose($fh);

?>
