<?php
	$styletext = 'table { border: solid 1px #fff; } table tr { vertical-align: top; }';
	function make_table($arrayname, $array) {
		$ret = "<table id=\"$arrayname\">\n";
		foreach ($array as $key => $value) {
			if (is_array($value)) {
				$ret .= "<tr><td>$key:</td><td>".make_table($key, $value)."</td></tr>\n";
			}
			else {
				$ret .= "<tr><td>$key:</td><td>$value</td></tr>\n";
			}
		}
		$ret .= "</table>\n";
		return $ret;
	}
	$maintext = make_table('rominfo', $rominfo);
?>
