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
		$type = $desc['type'];
		if ($type == 'assembly') {
			$asm = array_map(function($byte) { return ord($byte); }, str_split($data));
			return [$desc, $asm];
		}
		else if ($type == 'data') {
			$data = array_map(function($byte) { return ord($byte); }, str_split($data));
			$datasize = count($data);
			$entriesdesc = $desc['entries'];
			$entriescount = count($entriesdesc);
			$entries = [];
			for ($curByte = 0; $curByte < $datasize;) {
				$enty = [];
				foreach ($entriesdesc as $curEntry) {
					$entrysize = $curEntry['size'];
					$entryarray = array_slice($data, $curByte, $entrysize);
					$entrydata = null;
					$type = $curEntry['type'];
					for ($i = 0; $i < $entrysize; ++$i) {
						if ($type == 'standardtext') {
							$replacements = $this->getRomInfo()['texttables']['standardtext']['replacements'];
							if ($entryarray[$i] >= 0x20) {
								$entrydata .= $replacements[$entryarray[$i]];
							}
							else {
								$entrydata .= '['.str_pad(dechex($entryarray[$i]), 2, '0', STR_PAD_LEFT).']';
							}
						}
						else {
							$entrydata += $entryarray[$i] << ($i * 8);
						}
					}
					if ($type == 'pointer') {
						$entrydata = '$'.str_pad(dechex($entrydata), 6, '0', STR_PAD_LEFT);
					}
					$entry[$curEntry['name']] = $entrydata;
					$curByte += $entrysize;
				}
				array_push($entries, $entry);
			}
			return [$desc, $entries];
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
