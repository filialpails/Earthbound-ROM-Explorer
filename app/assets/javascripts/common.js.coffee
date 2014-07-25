$(document).ready ->
  $address = $('#address')

  $('#goto').click ->
    location.href = "/address/$#{('000000' + $address.val()).slice(-6)}"
