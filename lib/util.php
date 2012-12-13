<?php
/**
 * @file
 * Utility functions used elsewhere in the program.
 */
function isset_or(&$check, $alternate = null) {
	return (isset($check)) ? $check : $alternate;
}
/**
 * Converts a number to a hexidecimal string, padding it out to the given number of digits.
 * @param	int	$num	The number to convert.
 * @param	int	$digits	The number of digits in the result.
 * @author	filialpails
 */
function hexbyte($num, $digits = 2) {
	return str_pad(dechex($num), $digits, '0', STR_PAD_LEFT);
}
?>
