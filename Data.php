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
	
	public function getName() { return $this->name; }
	public function getSize() { return $this->size; }
	public function getTerminator() { return $this->terminator; }
	public function getData() { return $this->data; }
	public function getPrettyData() {
		return implode(' ', array_map(function($element) { return hexbyte($element); }, $this->data));
	}
}

class IntEntry extends DataEntry {
	public function __construct($name, $size, array $data) {
		parent::__construct($name, $size, null, $data);
	}
	
	public function getInt() {
		$data = $this->getData();
		$size = $this->getSize();
		$ret = 0;
		for ($i = 0; i < $size; ++$i) {
			$ret += $data[$i] << (8 * ($i + 1));
		}
		return $ret;
	}
}

class HexIntEntry extends DataEntry {
	public function __construct($name, $size, array $data) {
		parent::__construct($name, $size, null, $data);
	}
	
	public function getHex() {
		$data = $this->getData();
		$ret = '0x';
		foreach ($data as $byte) {
			$ret .= hexbyte($byte);
		}
		return $ret;
	}
}

class ByteArrayEntry extends DataEntry {
	//private $arr = [];
	
	public function __construct($name, $size, array $data) {
		parent::__construct($name, $size, null, $data);
		//$this->arr = $data;
	}
}

class BitfieldEntry extends DataEntry {
	private $bitvalues;
	
	public function __construct($name, $size, array $data, array $bitvalues) {
		parent::__construct($name, $size, null, $data);
		$this->bitvalues = $bitvalues;
	}
}

class PointerEntry extends HexIntEntry {
	public function getAddress() { return '$'.$this->getHex(); }
}

abstract class TextEntry extends DataEntry {
	protected $text = '';
	
	public function __construct($name, $size, $terminator, array $data) {
		parent::__construct($name, $size, $terminator, $data);
		$this->text = $this->decode($this->getData(), $terminator);
	}
	
	protected abstract function decode(array $hex, $terminator);
	
	public function getText() { return $this->text; }
}

class StandardTextEntry extends TextEntry {
	public static $textTable = [];
	
	public function __construct($name, $size, $terminator, array $data) {
		parent::__construct($name, $size, $terminator, $data);
	}
	
	protected function decode(array $hex, $terminator) {
		$cclengths = static::$textTable['lengths'];
		$replacements = static::$textTable['replacements'];
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
					$args .= ' '.hexbyte($hex[++$i]);
				}
				$text .= '['.hexbyte($opcode).$args.']';
				if ($opcode === $terminator) $text .= "\n";
			}
		}
		return $text;
	}
}

class StaffTextEntry extends TextEntry {
	public static $textTable = [];
	
	public function __construct($name, $size, $terminator, array $data) {
		parent::__construct($name, $size, $terminator, $data);
	}
	
	protected function decode(array $hex, $terminator) {
		$cclengths = static::$textTable['lengths'];
		$replacements = static::$textTable['replacements'];
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
					$args .= ' '.hexbyte($hex[++$i]);
				}
				$text .= '['.hexbyte($opcode).$args.']';
				if ($opcode === $terminator) $text .= "\n";
			}
		}
		return $text;
	}
}

class PaletteEntry extends DataEntry {
	private $colours;
	
	private static function readColour(array $b, $offset = 0) {
		$bgrBlock = (($b[$offset] & 0xff) | (($b[$offset + 1] & 0xff) << 8)) & 0x7FFF;
        return [($bgrBlock & 0x1f) * 8, (($bgrBlock >> 5) & 0x1f) * 8, ($bgrBlock >> 10) * 8];
	}
	
	private static function readPalette(array $b, $offset = 0) {
		$ret = [];
		for ($i = 0; $i < 16; ++$i) {
			array_push($ret, static::readColour($b, $offset + $i * 2));
		}
		return $ret;
	}
	
	public function __construct($name, $size, array $data) {
		parent::__construct($name, $size, null, $data);
		$this->colours = static::readPalette($data);
	}
	
	public function getColours() { return $this->colours; }
}

class TileEntry extends DataEntry {
	private $bpp;
	private $image = [];
	private $palette;
	
	private function read2BPPImage(array $source, $off, $x, $y, $bitOffset = 0) {
		$offset = $off;
		for ($i = 0; $i < 8; ++$i) {
			$iy = $i + $y;
			for ($k = 0; $k < 2; ++$k) {
				$b = $source[$off++];
				$kbitOffset = $k + $bitOffset;
				for ($j = 0; $j < 8; ++$j) {
					$index = (7 - $j) + $x;
					if (!isset($this->image[$index])) $this->image[$index] = [];
					if (!isset($this->image[$index][$iy])) $this->image[$index][$iy] = 0;
					$this->image[$index][$iy] |= (($b & (1 << $j)) >> $j) << $kbitOffset;
				}
			}
		}
		return $offset - $off;
	}
	
	private function read4BPPImage(array $source, $off, $x, $y, $bitOffset = 0) {
		$this->read2BPPImage($source, $off, $x, $y, $bitOffset);
		$this->read2BPPImage($source, $off + 16, $x, $y, $bitOffset + 2);
		return 32;
	}
	
	public function __construct($name, $size, array $data, $bpp, PaletteEntry $palette = null) {
		parent::__construct($name, $size, null, $data);
		$this->bpp = $bpp;
		switch ($this->bpp) {
		case 2:
			$this->read2BPPImage($data, 0, 0, 0);
			break;
		case 4:
			$this->read4BPPImage($data, 0, 0, 0);
		}
		$this->palette = $palette;
	}
	
	public function getBPP() { return $this->bpp; }
	public function getPalette() { return $this->palette; }
	public function getImage() { return $this->image; }
}

class Data extends AbstractData {
	private $entries = [];
	
	public function __construct($name, $description, $size, $terminator, $address) {
		parent::__construct($name, $description, $size, $terminator, $address);
	}
	
	public function addEntry(DataEntry $entry) { array_push($this->entries, $entry); }
	public function getEntries() { return $this->entries; }
}
?>
