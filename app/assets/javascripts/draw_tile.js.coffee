drawTile = (image, element, palette) ->
  canvas = document.getElementById(element)
  ctx = canvas.getContext('2d')
  ctx.mozImageSmoothingEnabled = false
  ctx.webkitImageSmoothingEnabled = false
  imagedata = ctx.createImageData(8, 8)
  data = imagedata.data
  for y in [0...8]
    for x in [0...8]
      index = (y * 8 + x) * 4
      paletteEntry = image[y][x]
      if palette
        p = palette[paletteEntry]
        data[  index] = p[0]
        data[++index] = p[1]
        data[++index] = p[2]
      else
        grey = paletteEntry * 0x11
        data[  index] = grey
        data[++index] = grey
        data[++index] = grey
      data[++index] = 0xff
  ctx.putImageData(imagedata, 0, 0)
  imageData = ctx.getImageData(0, 0, 8, 8)
  newCanvas = $('<canvas>').attr({
        width: imageData.width,
        height: imageData.height})[0]
  newCanvas.getContext('2d').putImageData(imageData, 0, 0)
  ctx.scale(8, 8)
  ctx.drawImage(newCanvas, 0, 0)
