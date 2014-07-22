window.drawTile = (image, element, palette) ->
  canvas = document.getElementById(element)
  ctx = canvas.getContext('2d')
  ctx.mozImageSmoothingEnabled = false
  ctx.webkitImageSmoothingEnabled = false
  imagedata = ctx.createImageData(8, 8)
  data = imagedata.data
  if palette != undefined
    for y in [0...8]
      for x in [0...8]
        index = (y * 8 + x) * 4
        paletteEntry = image[y][x]
        p = palette[paletteEntry]
        data[  index] = p[0]
        data[++index] = p[1]
        data[++index] = p[2]
        data[++index] = 0xff
  else
    for y in [0...8]
      for x in [0...8]
        index = (y * 8 + x) * 4
        paletteEntry = image[y][x]
        data[index] = data[index + 1] = data[index + 2] = paletteEntry * 0x11
        index += 3
        data[index] = 0xff
  ctx.putImageData(imagedata, 0, 0)
  ctx.scale(8, 8)
