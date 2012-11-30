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
				a:link, a:visited, a:hover {
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
					#titlelink {
						text-decoration: none;
					}
						#title {
							font-family: sans-serif;
							font-weight: normal;
							text-align: center;
						}
							#title1 {
								text-shadow: #000 1px 1px, #000 -1px 1px, #000 -1px -1px, #000 1px -1px, #000 0 2px, #000 0 3px, #000 0 4px, #000 0 5px;
								color: #fff;
							}
							#title2 {
								text-shadow: #fff 1px 1px, #fff -1px 1px, #fff -1px -1px, #fff 1px -1px;
								color: #DAA520;
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
			<a href="earthbound_rom_explorer.php" id="titlelink"><h1 id="title"><span id="title1">EARTHBOUND</span><br/><span id="title2">ROM Explorer</span></h1></a>
			<nav>
				<ul>
					<li><a href="earthbound_rom_explorer.php?rommap">ROM map</a></li>
					<li><a href="earthbound_rom_explorer.php?rammap">RAM map</a></li>
					<li>Go to: $<input type="text" size="6"/><button id="btn">Go</button></li>
				</ul>
			</nav>
		</div>
		<div id="middle">
			<?php echo $maintext; ?>
		</div>
	</body>
</html>

