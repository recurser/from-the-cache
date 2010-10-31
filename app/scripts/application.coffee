app: {
  init: ->
    app.show_messages()
    app.init_search()
    
  show_messages: ->
    $("#messages").slideDown('slow').fadeTo(3000, 1).slideUp('slow');
    
  init_search: ->
    $('form#search_form').submit app.handle_search
    
  handle_search: ->
    form = $(this)
    if form.length > 0
      document.location.href = '/' + $('input#search_field').attr('value')
      return false
    
}

$(document).ready app.init