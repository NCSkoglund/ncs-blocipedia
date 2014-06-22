# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

$ ->
  $("#alert").click ->
    alert @getAttribute("data-message")
    false

$ -> 
  $("#clickable").click ->
    $(this).hide()
    false

$ -> 
  $("#slideme").hover ->
    $("#clickable").show()
    false


$(document).on 'click', $(".private_field, input[type='checkbox']"), ->
  if $(".private_field, input[type='checkbox']").is(":checked")
    $('.js-new-user').removeClass 'js-hide'
  else
    $('.js-new-user').addClass 'js-hide'
