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
			$datadesc = (isset($_GET['name'])) ? $this->model->getFromName($_GET['name']) : $this->model->getFromAddress($_GET['address']);
			$desc = $datadesc[0];
			$data = $datadesc[1];
			$type = $desc['type'];
			if ($type == 'assembly') {
				$asm = array_map(function($byte) { return ord($byte); }, str_split($data));
				require 'viewasm.php';
			}
			else if ($type == 'data') {
				$maintext = print_r($desc, true);
				require 'viewdata.php';
			}
		}
		else if (isset($_GET['rommap'])) {
			$map = $this->model->getRomMap();
			require 'viewmap.php';
		}
		else if (isset($_GET['rammap'])) {
			$map = $this->model->getRamMap();
			require 'viewmap.php';
		}
		else {
			$rominfo = $this->model->getRomInfo();
			require 'viewrominfo.php';
		}
	}
}
?>
