<?php
require_once 'AbstractData.php';

class DataEntry {
	private $name;
	private $size;
	private $terminator;
	private $data;
	
	public function __construct($name, $size, $terminator, array $data) {
		$this->name = $name;
		$this->size = $size;
		$this->terminator = $terminator;
		$this->data = $data;
	}
	
	public function getName() {
		return $this->name;
	}
	
	public function getSize() {
		return $this->size;
	}
	
	public function getTerminator() {
		return $this->terminator;
	}
	
	public function getData() {
		return $this->data;
	}
	
	public function getPrettyData() {
		return implode(' ', array_map(function($element) { return str_pad(dechex($element), 2, '0', STR_PAD_LEFT); }, $this->data));
	}
}

class PointerEntry extends DataEntry {
	public function getAddress() {
		$data = $this->getData();
		$address = $data[0] + ($data[1] << 8) + ($data[2] << 16);
		return '$'.str_pad(dechex($address), 6, '0', STR_PAD_LEFT);
	}
}

abstract class TextEntry extends DataEntry {
	protected $textTable;
	protected $text = '';
	
	public function __construct($name, $size, $terminator, array $data, array $texttable) {
		parent::__construct($name, $size, $terminator, $data);
		$this->textTable = $texttable;
		$this->text = $this->decode($this->getData(), $terminator);
	}
	
	protected abstract function decode(array $hex, $terminator);
	
	public function getText() {
		return $this->text;
	}
}

class StandardTextEntry extends TextEntry {
	public function __construct($name, $size, $terminator, array $data, array $texttable) {
		parent::__construct($name, $size, $terminator, $data, $texttable);
	}
	
	protected function decode(array $hex, $terminator) {
		$cclengths = $this->textTable['lengths'];
		$replacements = $this->textTable['replacements'];
		$length = count($hex);
		$text = '';
		for ($i = 0; $i < $length; ++$i) {
			$opcode = $hex[$i];
			if (in_array($opcode, [0x15, 0x16, 0x17])) {
				$text .= $replacements[$opcode][$hex[++$i]];
			}
			else if (array_key_exists($opcode, $replacements)) {
				$text .= $replacements[$opcode];
			}
			else if ($opcode >= 0x00 && $opcode <= 0x1f) {
				$operandlength = 1;
				if (isset($cclengths[$opcode])) {
					$operandlength = $cclengths[$opcode];
				}
				if (is_array($operandlength)) {
					if (isset($operandlength[$hex[$i + 1]])) {
						$operandlength = $operandlength[$hex[$i + 1]];
					}
					else {
						$operandlength = $operandlength['default'];
					}
				}
				--$operandlength;
				$args = '';
				for ($j = 0; $j < $operandlength; ++$j) {
					$args .= ' '.str_pad(dechex($hex[++$i]), 2, '0', STR_PAD_LEFT);
				}
				$text .= '['.str_pad(dechex($opcode), 2, '0', STR_PAD_LEFT).$args.']';
				if ($opcode === $terminator) $text .= "\n";
			}
		}
		return $text;
	}
}

class StaffTextEntry extends TextEntry {
	public function __construct($name, $size, $terminator, array $data, array $texttable) {
		parent::__construct($name, $size, $terminator, $data, $texttable);
	}
	
	protected function decode(array $hex, $terminator) {
		$cclengths = $this->textTable['lengths'];
		$replacements = $this->textTable['replacements'];
		$length = count($hex);
		$text = '';
		for ($i = 0; $i < $length; ++$i) {
			$opcode = $hex[$i];
			if (array_key_exists($opcode, $replacements)) {
				$text .= $replacements[$opcode];
			}
			else {
				$operandlength = 1;
				if (isset($cclengths[$opcode])) {
					$operandlength = $cclengths[$opcode];
				}
				--$operandlength;
				$args = '';
				for ($j = 0; $j < $operandlength; ++$j) {
					$args .= ' '.str_pad(dechex($hex[++$i]), 2, '0', STR_PAD_LEFT);
				}
				$text .= '['.str_pad(dechex($opcode), 2, '0', STR_PAD_LEFT).$args.']';
				if ($opcode === $terminator) $text .= "\n";
			}
		}
		return $text;
	}
}

class Data extends AbstractData {
	private $entries = [];
	
	public function __construct($name, $description, $size, $terminator, $address) {
		parent::__construct($name, $description, $size, $terminator, $address);
	}
	
	public function addEntry(DataEntry $entry) {
		array_push($this->entries, $entry);
	}
	
	public function getEntries() {
		return $this->entries;
	}
}
?>
