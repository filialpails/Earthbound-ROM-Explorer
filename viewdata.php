<?php
	$maintext = '<pre>';
	foreach ($data as $element) {
		$maintext .= '0x'.str_pad(dechex($element), 2, '0', STR_PAD_LEFT)."\n";
	}
	$maintext .= '</pre>';
?>
