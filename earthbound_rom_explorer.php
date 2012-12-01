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
			@font-face {
				font-family: "Apple Kid";
				src: local("Apple Kid"), url("apple_kid.ttf");
			}
			@font-face {
				font-family: "Saturn Boing";
				src: local("Saturn Boing"), url("saturn_boing.ttf");
			}
			@font-face {
				font-family: StatusPlz;
				src: local(StatusPlz), url("statusplz.ttf");
			}
			@font-face {
				font-family: "The Font Against Giygas";
				src: local("The Font Against Giygas"), url("gasfont.ttf");
			}
			body {
				text-align: center;
				background-color: #f00;
				color: #fff;
				font-family: "Apple Kid", sans-serif;
				font-size: 16px;
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
					#title {
						font-family: "The Font Against Giygas", sans-serif;
						font-weight: normal;
						text-align: center;
					}
						#titlelink {
							text-decoration: none;
						}
							#title1 {
								text-shadow: #000 1px 1px, #000 -1px 1px, #000 -1px -1px, #000 1px -1px, #000 0 2px, #000 0 3px, #000 0 4px, #000 0 5px, #000 0 6px, #000 0 7px, #000 0 8px, #000 0 9px, #000 0 10px, #000 0 11px, #000 0 12px, #000 0 13px, #000 0 14px, #000 0 15px, #000 0 16px, #000 0 17px, #000 0 18px, #000 0 19px, #000 0 20px;
								color: #fff;
							}
							#title2 {
								text-shadow: #fff 1px 1px, #fff -1px 1px, #fff -1px -1px, #fff 1px -1px;
								color: #DAA520;
							}
				#middle {
					font-family: StatusPlz, monospace;
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
		<script>
			document.addEventListener('DOMContentLoaded', function() {
				document.getElementById('btn').addEventListener('click', function() {
					location.href = 'earthbound_rom_explorer.php?address=' + document.getElementById('addr').value;
				});
			});
		</script>
		<?php echo $scripttext; ?>
	</head>
	<body>
		<div id="left">
			<h1 id="title">
				<a href="earthbound_rom_explorer.php" id="titlelink">
					<span id="title1">EARTHBOUND</span><br/><br/>
					<span id="title2">ROM EXPLORER</span>
				</a>
			</h1>
			<nav>
				<ul>
					<li><a href="earthbound_rom_explorer.php?rommap">ROM map</a></li>
					<li><a href="earthbound_rom_explorer.php?rammap">RAM map</a></li>
					<li>Go to: $<input id="addr" type="text" size="6"/><button id="btn">Go</button></li>
				</ul>
			</nav>
		</div>
		<div id="middle">
			<?php echo $maintext; ?>
		</div>
	</body>
</html>

