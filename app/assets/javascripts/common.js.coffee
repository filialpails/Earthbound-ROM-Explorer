$(document).ready ->
  $address = $('#address')
  $('#goto').click ->
    location.href = '/address/#{$address.val()}'
