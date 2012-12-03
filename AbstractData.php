<?php
abstract class AbstractData {
	private $description;
	private $name;
	private $size;
	private $terminator;
	private $address;
	
	public function __construct($name, $description, $size, $terminator, $address) {
		$this->name = $name;
		$this->description = $description;
		$this->size = $size;
		$this->terminator = $terminator;
		$this->address = $address;
	}
	
	public function getDescription() {
		return $this->description;
	}
	
	public function getName() {
		return $this->name;
	}
	
	public function getSize() {
		return $this->size;
	}
	
	public function getAddress() {
		return $this->address;
	}
	
	public function getTerminator() {
		return $this->terminator;
	}
}
?>
