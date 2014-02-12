$(document).ready ->
  $address = $('#address')

  addressify = (addr) ->
    ('00000' + addr).slice(-6)

  $('#goto').click ->
    location.href = "/address/$#{addressify($address.val())}"
