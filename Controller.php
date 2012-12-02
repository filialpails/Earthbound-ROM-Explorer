<?php
require_once 'Model.php';
require_once 'View.php';

class Controller {
	private $model;
	private $view;
	
	public function __construct($yamlfile, $romfile) {
		$this->model = new Model($yamlfile, $romfile);
		$this->view = new View();
	}
	
	public function invoke() {
		if (isset($_GET['name']) || isset($_GET['address'])) {
			list($desc, $data) = isset($_GET['name']) ? $this->model->getFromName($_GET['name']) : $this->model->getFromAddress($_GET['address']);
			$type = $desc['type'];
			if ($type == 'assembly') {
				$this->view->formatASM($desc, $data);
			}
			else if ($type == 'data') {
				$this->view->formatData($data);
			}
		}
		else if (isset($_GET['rommap'])) {
			$map = $this->model->getRomMap();
			$this->view->formatRomMap($map);
		}
		else if (isset($_GET['rammap'])) {
			$map = $this->model->getRamMap();
			$this->view->formatRamMap($map);
		}
		else {
			$rominfo = $this->model->getRomInfo();
			$this->view->formatRomInfo($rominfo);
		}
	}
	
	public function getView() {
		return $this->view;
	}
}
?>
