<?php
function isset_or(&$check, $alternate = null) {
	return (isset($check)) ? $check : $alternate;
}
?>
