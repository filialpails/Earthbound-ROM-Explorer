<?php
require_once "Model.php";

class Controller {
	private $model;
	
	public function __construct($yamlfile, $romfile) {
		$this->model = new Model($yamlfile, $romfile);
	}
	
	public function invoke() {
		global $maintext, $scripttext, $styletext;
		if (isset($_GET['name']) || isset($_GET['address'])) {
			list($desc, $data) = (isset($_GET['name'])) ? $this->model->getFromName($_GET['name']) : $this->model->getFromAddress($_GET['address']);
			$type = $desc['type'];
			if ($type == 'assembly') {
				$asm = array_map(function($byte) { return ord($byte); }, str_split($data));
				require 'viewasm.php';
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
						$entrydata = 0;
						for ($i = 0; $i < $entrysize; ++$i) {
							$entrydata += $entryarray[$i] << ($i * 8);
						}
						$entry[ $curEntry['name']] = $entrydata;
						$curByte += $entrysize;
					}
					array_push($entries, $entry);
				}
				require 'viewdata.php';
			}
		}
		else if (isset($_GET['rommap'])) {
			$map = $this->model->getRomMap();
			require 'viewrommap.php';
		}
		else if (isset($_GET['rammap'])) {
			$map = $this->model->getRamMap();
			require 'viewrammap.php';
		}
		else {
			$rominfo = $this->model->getRomInfo();
			require 'viewrominfo.php';
		}
	}
}
?>
