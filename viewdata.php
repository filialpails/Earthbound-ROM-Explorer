<?php
	foreach ($entries as $entry) {
		foreach ($entry as $key => $value) {
			$maintext .= "$key: $value<br/>";
		}
		$maintext .= '---<br/>';
	}
?>
