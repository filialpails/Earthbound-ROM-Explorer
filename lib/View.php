<?php
/**
 * @author	filialpails
 */
class View {
	private $maintext = '';
	private $style = '';
	private $script = '';
	private $extratext = '';
	
	public function __construct() {
	}
	
	public function formatRomInfo(array $rominfo) {
		$this->maintext .= '<h2>Earthbound (U) [!]</h2>';
		function make_table($arrayname, $array) {
			$ret = "<table id=\"$arrayname\">\n";
			foreach ($array as $key => $value) {
				$ret .= "<tr><td>$key:</td><td>";
				$ret .= is_array($value) ? make_table($key, $value) : $value;
				$ret .= "</td></tr>\n";
			}
			$ret .= "</table>\n";
			return $ret;
		}
		$this->maintext .= make_table('rominfo', $rominfo);
	}
	
	public function formatRomMap(array $map) {
		$this->maintext .= '<h2>ROM Map</h2>';
		foreach ($map as $item) {
			$offset = '$'.hexbyte($item['offset'], 6);
			if (isset($item['name'])) {
				$name = $item['name'];
				$description = isset_or($item['description'], '');
				$this->maintext .= "$offset - <a href=\"index.php?name=$name\" title=\"$description\">$name</a><br/>";
			}
		}
	}
	
	public function formatRamMap(array $map) {
		$this->maintext .= '<h2>RAM Map</h2>';
		foreach ($map as $item) {
			$offset = '$'.hexbyte($item['offset'], 6);
			if (isset($item['name'])) {
				$name = $item['name'];
				$description = isset_or($item['description'], '');
				$this->maintext .= "$offset - <abbr title=\"$description\">$name</abbr><br/>";
			}
		}
	}
	
	public function formatASM(ASM $asm, array $programnames = null, array $datanames = null) {
		$localvars = $asm->getLocalVars();
		$json_asm = json_encode($asm->getHex());
		$json_labels = json_encode($asm->getLabels());
		$json_prognames = json_encode($programnames);
		$json_datanames = json_encode($datanames);
		$json_localvars = json_encode($localvars);
		$this->script .=
			"<script src=\"js/65816.js\"></script>
			<script>
				_65816.named_memory_locations['programbank'] = $json_prognames;
				_65816.named_memory_locations['databank'] = $json_datanames;
				_65816.named_memory_locations['directpage'] = $json_localvars;
				\$(document).ready(function() {
					\$('#middle').append('<pre>' + _65816.disassemble($json_asm, {$asm->getAddress()}, $json_labels) + '</pre>');
				});
			</script>";
		$this->maintext .= "<h2>{$asm->getName()}</h2>";
		$this->style .= '#right { display: block; }';
		$this->extratext .= "<p>{$asm->getDescription()}</p>";
		$arguments = $asm->getArguments();
		if (count($arguments)) {
			$this->extratext .= 'Arguments:<table>';
			foreach ($arguments as $name => $desc) {
				$this->extratext .= "<tr><td>$name:</td><td>$desc</td></tr>";
			}
			$this->extratext .= '</table>';
		}
		if (count($localvars)) {
			$this->extratext .= 'Local variables:<table>';
			foreach ($localvars as $name => $address) {
				$this->extratext .= "<tr><td>$address:</td><td>$".hexbyte($name).'</td></tr>';
			}
			$this->extratext .= '</table>';
		}
	}
	
	public function formatData(Data $data) {
		$this->maintext .= "<h2>{$data->getName()}</h2>\n";
		$this->maintext .= "<table>\n";
		$entries = $data->getEntries();
		$i = 0;
		foreach ($entries as $entry) {
			$this->maintext .= "<tr><td>{$entry->getName()}:</td><td>";
			if (is_subclass_of($entry, 'TextEntry')) {
				$text = htmlspecialchars($entry->getText(), ENT_HTML5);
				$this->maintext .= "<pre>$text</pre>";
			}
			else if (get_class($entry) === 'PointerEntry') {
				$this->maintext .= "<pre>{$entry->getAddress()}</pre>";
			}
			else if (get_class($entry) === 'TileEntry') {
				$image = $entry->getImage();
				$json_image = json_encode($image);
				$pal = json_encode($entry->getPalette() ? $entry->getPalette()->getColours() : null);
				$this->maintext .= "<canvas id='{$entry->getName()}$i' width='64' height='64'></canvas>";
				$this->script .= "
					<script src=\"js/drawTile.js\"></script>
					<script>
						\$(document).ready(function() {
							drawTile($json_image, '{$entry->getName()}$i', $pal);
						});
					</script>";
			}
			else if (get_class($entry) === 'PaletteEntry') {
				$colours = $entry->getColours();
				foreach ($colours as $colour) {
					$this->maintext .= "<div style=\"background-color: rgb({$colour[0]},{$colour[1]},{$colour[2]}); width: 32px; height: 32px; float: left;\"></div>";
				}
			}
			else if (is_subclass_of($entry, 'NumberEntry')) {
				$this->maintext .= $entry->getNumber();
			}
			else {
				$this->maintext .= $entry->getPrettyData();
			}
			$this->maintext .= "</td></tr>\n";
			++$i;
		}
		$this->maintext .= "</table>\n---<br/>\n";
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
	public function getExtraText() {
		return $this->extratext;
	}
}
?>
