<?php
   // requires eb.yml from PKHackers/EBYAML.git, a headerless Earthbound ROM (expanded should be okay), and filialpails/65816.js.git to disassemble the ASM listings
   $YAMLFILE = 'eb.yml';
   $ROMFILE = 'earthbound.smc';
   function file2snes($offset) {
    return 0xc00000 + ($offset & 0x3fffff);
   }
   function snes2file($addr) {
    return $addr & 0x3fffff;
   }
   $ebyaml = yaml_parse_file($YAMLFILE, -1);
   $rom = fopen($ROMFILE, 'rb');
   $rominfo = $ebyaml[0];
   $memmap = $ebyaml[1];
   $address = isset($_GET['address']) ? $_GET['address'] : null;
   $text = '';
   $data = null;
   if (isset($address)) {
    $mem = array_reduce($memmap, function($result, $element) use($address) {
     if (dechex($element['offset']) == $address) {
      $result = $element;
     }
     return $result;
    });
    $type = $mem['type'];
    if ($type == 'assembly') {
     fseek($rom, snes2file(intval($mem['offset'])));
     $data = fread($rom, intval($mem['size']));
     $length = strlen($data) / 2;
     $arr = [];
     for ($i = 0; $i < $length; ++$i) {
      $arr[$i] = ord(substr($data, $i * 2, 2));
     }
     $data = $arr;
    }
    else if ($type == 'data') {
     $text = implode(", ", $mem['entries']);
    }
   }
   else {
    $rammap = array_filter($memmap, function($element) {
     return $element['offset'] >= 0x7e0000 && $element['offset'] <= 0x7fffff;
    });
    $rommap = array_filter($memmap, function($element) {
     return !($element['offset'] >= 0x7e0000 && $element['offset'] <= 0x7fffff);
    });
    $text = '<h1>ROM map</h1>';
    $text .= '<ul>';
    foreach ($rommap as $item) {
     $offset = dechex($item['offset']);
     $type = isset($item['type']) ? $item['type'] : null;
     $name = isset($item['name']) ? $item['name'] : "\$$offset";
     $description = isset($item['description']) ? $item['description'] : 'No description.';
     $text .= "<li><a href=\"ebyaml_explore.php?address=$offset\" title=\"$description\">$name</a></li>\n";
    }
    $text .= '</ul>';
    $text .= '<ul>';
    $text .= '<h1>RAM map</h1>';
    foreach ($rammap as $item) {
     $offset = dechex($item['offset']);
     $type = isset($item['type']) ? $item['type'] : null;
     $name = isset($item['name']) ? $item['name'] : "\$$offset";
     $description = isset($item['description']) ? $item['description'] : 'No description.';
     $text .= "<li><a href=\"ebyaml_explore.php?address=$offset\" title=\"$description\">$name</a></li>\n";
    }
    $text .= '</ul>';
   }
?>
<!doctype html>
<html>
 <head>
  <meta charset="utf-8"/>
  <title>Earthbound ROM Explorer</title>
  <script src="65816.js"></script>
  <script>
   document.addEventListener('DOMContentLoaded', function() {
    document.getElementById("asm").textContent = _65816.disassemble(<?php echo json_encode($data); ?>);
   });
  </script>
 </head>
 <body>
  <?php echo $text; ?>
  <pre id="asm"></pre>
 </body>
</html>
