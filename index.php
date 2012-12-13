<!doctype html>
<html>
	<head>
		<meta charset="utf-8"/>
		<title>Earthbound ROM Explorer</title>
		<link rel="stylesheet" href="css/normalize.css"/>
		<link rel="stylesheet" href="css/ebromexplorer.css"/>
		<?php
			require_once './lib/Controller.php';
			$controller = new Controller();
			$controller->invoke();
			$view = $controller->getView();
		?>
		<style>
			<?php echo $view->getStyle(); ?>
		</style>
		<script src="http://ajax.googleapis.com/ajax/libs/jquery/1.8.3/jquery.min.js"></script>
		<script>
			$(document).ready( function() {
				$('#btn').click(function() {
					location.href = 'index.php?address=' + $('#addr').val();
				});
			});
		</script>
		<?php echo $view->getScript(); ?>
	</head>
	<body>
		<div id="left">
			<h1 id="title">
				<a href="index.php" id="titlelink">
					<span id="title1">Earthbound</span><br/>
					<span id="title2">ROM Explorer</span>
				</a>
			</h1>
			<nav>
				<ul>
					<li><a href="index.php?rommap">ROM map</a></li>
					<li><a href="index.php?rammap">RAM map</a></li>
					<li>Go to: $<input id="addr" type="text" size="6"/><button id="btn">Go</button></li>
				</ul>
			</nav>
		</div>
		<div id="middle">
			<?php echo $view->getMainText(); ?>
		</div>
		<div id="right">
			<?php echo $view->getExtraText(); ?>
		</div>
	</body>
</html>

