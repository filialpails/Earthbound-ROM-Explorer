<?php
require_once 'util.php';
require_once 'ASM.php';
require_once 'Data.php';

class Model {
	private $rominfo;
	private $map;
	private $romfile;
	
	private static function file2snes($offset) {
		return 0xc00000 + ($offset & 0x3fffff);
	}

	private static function snes2file($addr) {
		return $addr & 0x3fffff;
	}
	
	public function __construct($yamlfile, $romfile) {
		$ebyaml = yaml_parse_file($yamlfile, -1);
		$this->rominfo = $ebyaml[0];
		$this->map = $ebyaml[1];
		$this->romfile = $romfile;
		$replacements = &$this->rominfo['texttables']['standardtext']['replacements'];
		unset($this->rominfo['texttables']['standardtext']['replacements'][0x00]);
		unset($this->rominfo['texttables']['standardtext']['replacements'][0x03]);
		$replacements[0x52] = '"';
		$replacements[0x52] = '#';
		$replacements[0x55] = '%';
		$replacements[0x56] = '&';
		$replacements[0x5b] = '+';
		$replacements[0x5f] = '/';
		$replacements[0x6a] = ':';
		$replacements[0x6b] = ';';
		$replacements[0x6c] = '<';
		$replacements[0x6d] = '=';
		$replacements[0x6e] = '>';
		$replacements[0x8b] = 'α';
		$replacements[0x8c] = 'β';
		$replacements[0x8d] = 'γ';
		$replacements[0x8e] = 'Σ';
		$replacements[0x90] = '`';
		$replacements[0xab] = '{';
		$replacements[0xac] = '|';
		$replacements[0xad] = '}';
		$replacements[0xae] = '~';
		$replacements[0xaf] = '◯';
		$staffreplacements = &$this->rominfo['texttables']['stafftext']['replacements'];
		unset($this->rominfo['texttables']['stafftext']['replacements'][0x00]);
		$staffreplacements[0x41] = '!';
		$staffreplacements[0x43] = '#';
		$staffreplacements[0x4c] = ',';
		$staffreplacements[0x4d] = '-';
		$staffreplacements[0x4e] = '.';
		$staffreplacements[0x4f] = '/';
		$staffreplacements[0x58] = 'j';
		$staffreplacements[0x60] = '0';
		$staffreplacements[0x61] = '1';
		$staffreplacements[0x62] = '2';
		$staffreplacements[0x63] = '3';
		$staffreplacements[0x64] = '4';
		$staffreplacements[0x65] = '5';
		$staffreplacements[0x66] = '6';
		$staffreplacements[0x67] = '7';
		$staffreplacements[0x68] = '8';
		$staffreplacements[0x69] = '9';
		$staffreplacements[0x6a] = 'q';
		$staffreplacements[0x7e] = 'z';
		$staffreplacements[0x80] = '_';
		$staffreplacements[0xad] = ';';
		$staffreplacements[0xcc] = '|';
		$staffreplacements[0xce] = '~';
		$staffreplacements[0xcf] = '◯';
	}
	
	public function getRomInfo() {
		return $this->rominfo;
	}
	
	public function getFromName($name) {
		$address = dechex($this->map[$name]['offset']);
		return $this->getFromAddress($address);
	}
	
	public function getFromAddress($address) {
		$desc = $this->map[hexdec($address)];
		$rom = fopen($this->romfile, 'rb');
		fseek($rom, static::snes2file(intval($desc['offset'])));
		$data = fread($rom, intval($desc['size']));
		fclose($rom);
		$type = isset_or($desc['type']);
		$name = isset_or($desc['name'], '');
		$description = isset_or($desc['description'], '');
		if ($type === 'assembly') {
			$asm = array_map(function($byte) { return ord($byte); }, str_split($data));
			$labels = isset_or($desc['labels'], []);
			$args = isset_or($desc['arguments'], []);
			return new ASM($name, $description, $desc['size'], null, $desc['offset'], $asm, $labels, $args);
		}
		else if ($type === 'data') {
			$data = array_map(function($byte) { return ord($byte); }, str_split($data));
			$size = isset_or($desc['size']);
			$terminator = isset_or($desc['terminator']);
			$dataObj = new Data($name, $description, $size, $terminator, $desc['offset']);
			if (isset($desc['entries'])) {
				$entries = $desc['entries'];
				for ($i = 0; $i < $size;) {
					foreach ($entries as $entry) {
						$entryname = $entry['name'];
						$entrydata = [];
						$entrysize = null;
						if (isset($entry['size'])) {
							$entrysize = $entry['size'];
							$entrydata = array_slice($data, $i, $entrysize);
						}
						$entryterm = null;
						if (isset($entry['terminator'])) {
							$entryterm = $entry['terminator'];
							$entrydata = $data;
						}
						$entrytype = isset_or($entry['type']);
						$entryObj = null;
						if ($entrytype === 'standardtext') {
							$entryObj = new StandardTextEntry($entryname, $entrysize, $entryterm, $entrydata, $this->rominfo['texttables']['standardtext']);
						}
						else if ($entrytype === 'stafftext') {
							$entryObj = new StaffTextEntry($entryname, $entrysize, $entryterm, $entrydata, $this->rominfo['texttables']['stafftext']);
						}
						else if ($entrytype === 'pointer') {
							$entryObj = new PointerEntry($entryname, $entrysize, $entryterm, $entrydata);
						}
						else {
							$entryObj = new DataEntry($entryname, $entrysize, $entryterm, $entrydata);
						}
						$dataObj->addEntry($entryObj);
						if ($entrysize === null) $entrysize = count($entryObj->getData());
						$i += $entrysize;
					}
				}
			}
			else {
				$dataEntry = new DataEntry('Data', $desc['size'], null, $data);
				$dataObj.addEntry($dataEntry);
			}
			return $dataObj;
		}
	}
	
	public function getRomMap() {
		return array_filter($this->map, function($element) {
			return $element['offset'] < 0x7e0000 || $element['offset'] > 0x7fffff;
		});
	}
	
	public function getRamMap() {
		return array_filter($this->map, function($element) {
			return $element['offset'] >= 0x7e0000 && $element['offset'] <= 0x7fffff;
		});
	}
}
?>
