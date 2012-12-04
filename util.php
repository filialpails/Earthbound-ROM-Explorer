<?php
function isset_or(&$check, $alternate = null) {
	return (isset($check)) ? $check : $alternate;
}

function hexbyte($num, $digits = 2) {
	return str_pad(dechex($num), $digits, '0', STR_PAD_LEFT);
}
?>
