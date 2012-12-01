<?php
	foreach ($map as $item) {
		$offset = '$'.str_pad(dechex($item['offset']), 6, '0', STR_PAD_LEFT);
		if (isset($item['name'])) {
			$name = $item['name'];
			$description = isset($item['description']) ? $item['description'] : '';
			$maintext .= "$offset - <span title=\"$description\">$name</span><br/>";
		}
	}
?>
