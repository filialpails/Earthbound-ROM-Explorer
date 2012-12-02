<?php
class View {
	private $maintext;
	private $style;
	private $script;
	
	public function __construct() {
		$this->maintext = '';
		$this->script = '';
		$this->style = '';
	}
	
	public function formatRomInfo($rominfo) {
		$this->style = 'tr { vertical-align: top; }';
		function make_table($arrayname, $array) {
			$ret = "<table id=\"$arrayname\">\n";
			foreach ($array as $key => $value) {
				if (is_array($value)) {
					$ret .= "<tr><td>$key:</td><td>".make_table($key, $value)."</td></tr>\n";
				}
				else {
					$ret .= "<tr><td>$key:</td><td>$value</td></tr>\n";
				}
			}
			$ret .= "</table>\n";
			return $ret;
		}
		$this->maintext = make_table('rominfo', $rominfo);
	}
	
	public function formatRomMap($map) {
		foreach ($map as $item) {
			$offset = '$'.str_pad(dechex($item['offset']), 6, '0', STR_PAD_LEFT);
			if (isset($item['name'])) {
				$name = $item['name'];
				$description = isset($item['description']) ? $item['description'] : '';
				$this->maintext .= "$offset - <a href=\"earthbound_rom_explorer.php?name=$name\" title=\"$description\">$name</a><br/>";
			}
		}
	}
	
	public function formatRamMap($map) {
		foreach ($map as $item) {
			$offset = '$'.str_pad(dechex($item['offset']), 6, '0', STR_PAD_LEFT);
			if (isset($item['name'])) {
				$name = $item['name'];
				$description = isset($item['description']) ? $item['description'] : '';
				$this->maintext .= "$offset - <span title=\"$description\">$name</span><br/>";
			}
		}
	}
	
	public function formatASM($desc, $asm) {
		$json_asm = json_encode($asm);
		$json_labels = json_encode(isset($desc['labels']) ? $desc['labels'] : []);
		$this->script = "
			<script src=\"65816.js\"></script>
			<script>
				\$(document).ready(function() {
					\$('#middle').html('<pre>' + _65816.disassemble($json_asm, {$desc['offset']}, $json_labels) + '</pre>');
				});
			</script>";
		$this->maintext = "<h2>{$desc['name']}</h2>";
	}
	
	public function formatData($data) {
		foreach ($data as $entry) {
			foreach ($entry as $key => $value) {
				$this->maintext .= "$key: $value<br/>";
			}
			$this->maintext .= '---<br/>';
		}
	}
	
	public function getMainText() {
		return $this->maintext;
	}
	public function getScript() {
		return $this->script;
	}
	public function getStyle() {
		return $this->style;
	}
}
?>
