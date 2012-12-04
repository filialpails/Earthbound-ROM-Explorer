function drawTile(image, element, palette) {
	var canvas = document.getElementById(element);
	var ctx = canvas.getContext('2d');
	ctx.mozImageSmoothingEnabled = false;
	ctx.webkitImageSmoothingEnabled = false;
	var imagedata = ctx.createImageData(8, 8);
	var data = imagedata.data;
	for (var y = 0; y < 8; ++y) {
		for (var x = 0; x < 8; ++x) {
			var index = (y * 8 + x) * 4;
			var paletteEntry = image[x][y];
			var grey = palette ? null : paletteEntry * 0x11;
			data[index++] = palette ? palette[paletteEntry][0] : grey;
			data[index++] = palette ? palette[paletteEntry][1] : grey;
			data[index++] = palette ? palette[paletteEntry][2] : grey;
			data[index]   = 0xff;
		}
	}
	ctx.putImageData(imagedata, 0, 0);
	var imageData = ctx.getImageData(0, 0, 8, 8);
	var newCanvas = $("<canvas>").attr("width", imageData.width).attr("height", imageData.height)[0];
	newCanvas.getContext("2d").putImageData(imageData, 0, 0);
	ctx.scale(8, 8);
	ctx.drawImage(newCanvas, 0, 0);
}
