<?php
	$maintext = '<pre>';
	foreach ($map as $item) {
		$offset = dechex($item['offset']);
		$prettyoffset = '$'.str_pad($offset, 6, '0', STR_PAD_LEFT);
		if (isset($item['name'])) {
			$name = $item['name'];
			$description = isset($item['description']) ? $item['description'] : '';
			$maintext .= "$prettyoffset - <span title=\"$description\">$name</span>\n";
		}
	}
	$maintext .= '</pre>';
?>
