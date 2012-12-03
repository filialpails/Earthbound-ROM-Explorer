<?php
require_once 'AbstractData.php';

class ASM extends AbstractData {
	private $labels;
	private $arguments;
	private $hex;
	
	public function __construct($name, $description, $size, $terminator, $address, $hex, $labels, $arguments) {
		parent::__construct($name, $description, $size, $terminator, $address);
		$this->hex = $hex;
		$this->labels = $labels;
		$this->arguments = $arguments;
	}
	
	public function getHex() {
		return $this->hex;
	}
	
	public function getLabels() {
		return $this->labels;
	}
	
	public function getArguments() {
		return $this->arguments;
	}
}
?>
