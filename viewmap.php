<?php
	foreach ($map as $item) {
		$offset = dechex($item['offset']);
		$prettyoffset = '$'.str_pad($offset, 6, '0', STR_PAD_LEFT);
		if (isset($item['name'])) {
			$name = $item['name'];
			$description = isset($item['description']) ? $item['description'] : '';
			$maintext .= "$prettyoffset - <a href=\"earthbound_rom_explorer.php?address=$offset\" title=\"$description\">$name</a><br/>\n";
		}
	}
?>
