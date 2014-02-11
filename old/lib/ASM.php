<?php
require_once './lib/AbstractData.php';
/**
 * Represents a block of 65816 assembly.
 * @author	filialpails
 */
class ASM extends AbstractData {
	private $labels;
	private $arguments;
	private $hex;
	private $localvars;
	
	public function __construct($name, $description, $size, $address, array $hex, array $labels = [], array $arguments = [], array $localvars = []) {
		parent::__construct($name, $description, $size, null, $address);
		$this->hex = $hex;
		$this->labels = $labels;
		$this->arguments = $arguments;
		$this->localvars = $localvars;
	}
	
	public function getHex() { return $this->hex; }
	public function getLabels() { return $this->labels; }
	public function getArguments() { return $this->arguments; }
	public function getLocalVars() { return $this->localvars; }
}
?>
