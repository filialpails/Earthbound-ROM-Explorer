<?php
	require_once 'Controller.php';
	$maintext = '';
	$styletext = '';
	$scripttext = '';
	$controller = new Controller('eb.yml', 'earthbound.smc');
	$controller->invoke();
?>
<!doctype html>
<html>
	<head>
		<meta charset="utf-8"/>
		<title>Earthbound ROM Explorer</title>
		<link rel="stylesheet" href="normalize.css"/>
		<style>
			body {
				text-align: center;
				background-color: #f00;
				color: #fff;
			}
				#left {
					text-align: left;
					position: fixed;
					top: 0;
					bottom: 0;
					left: 0;
					margin: 15px;
				}
					#title {
						color: #fff;
						font-family: sans-serif;
						font-weight: normal;
						text-shadow: #000 1px 1px, #000 -1px 1px, #000 -1px -1px, #000 1px -1px;
						text-align: center;
					}
				#middle {
					padding: 1em;
					border: 5px ridge #fff;
					border-radius: 3px;
					margin: auto;
					text-align: left;
					background-color: #000;
					overflow: auto;
					width: 768px;
					height: 672px;
				}
				<?php echo $styletext; ?>
		</style>
		<?php echo $scripttext; ?>
	</head>
	<body>
		<div id="left">
			<a href="earthbound_rom_explorer.php"><h1 id="title">Earthbound<br/>ROM Explorer</h1></a>
			<nav>
				<ul>
					<li><a href="earthbound_rom_explorer.php?rommap">ROM map</a></li>
					<li><a href="earthbound_rom_explorer.php?rammap">RAM map</a></li>
					<li>Go to address: $<input type="text" size="6"/></li>
				</ul>
			</nav>
		</div>
		<div id="middle">
			<?php echo $maintext; ?>
		</div>
	</body>
</html>

