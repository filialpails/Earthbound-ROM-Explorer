<?php
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
		return [$desc, $data];
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
