# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

remove = -> 
  $('form').on 'click', '.remove_fields', (event) ->
    $(this).prev('input[type=hidden]').val('1')
    $(this).closest('fieldset').hide()
    event.preventDefault() 

add = ->
  $('form').on 'click', '.add_fields', (event) ->
    time = new Date().getTime()
    regexp = new RegExp($(this).data('id'), 'g')
    $(this).before($(this).data('fields').replace(regexp, time))
    event.preventDefault()

display = ->
  if $("#private_field").is(":checked")
    $('.js-new-user').removeClass 'js-hide'   

checkbox = ->
  $('form').on 'click', $("#private_field"), ->
    if $("#private_field").is(":checked")
      $('.js-new-user').removeClass 'js-hide'
    else
      $('.js-new-user').addClass 'js-hide'  

$(document).ready(remove)
$(document).on('page:load', remove)
$(document).ready(add)
$(document).on('page:load', add)
$(document).ready(display)
$(document).on('page:load', display)
$(document).ready(checkbox)
$(document).on('page:load', checkbox)
