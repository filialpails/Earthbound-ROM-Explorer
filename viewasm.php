<?php
		$json = json_encode($asm);
		$scripttext = "<script src=\"65816.js\"></script><script>document.addEventListener('DOMContentLoaded', function() { document.getElementById('middle').innerHTML = '<pre>' + _65816.disassemble($json) + '</pre>'; });</script>";
?>
