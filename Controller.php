<?php
require_once 'Model.php';
require_once 'View.php';

class Controller {
	private $model;
	private $view;
	
	public function __construct() {
		$this->model = new Model('eb.yml', 'earthbound.smc');
		$this->view = new View();
	}
	
	public function invoke() {
		if (isset($_GET['name']) || isset($_GET['address'])) {
			$data = isset($_GET['name']) ? $this->model->getFromName($_GET['name']) : $this->model->getFromAddress($_GET['address']);
			$type = get_class($data);
			if ($type === 'ASM') {
				$this->view->formatASM($data);
			}
			else if ($type === 'Data') {
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
