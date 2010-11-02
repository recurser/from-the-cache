app: {
  init: ->
    app.show_messages()
    app.init_search()
    app.init_search_result()
    
  show_messages: ->
    $("#messages").slideDown('slow').fadeTo(3000, 1).slideUp('slow');
    
  init_search: ->
    $('form#search_form').submit app.handle_search
    
  init_search_result: ->
    if $('base').length > 0
      scrape_source = unescape $('input#scrape_source').attr('value')
      if scrape_source.indexOf('webcache.googleusercontent.com') > 0
        link_text = 'the cache'
      else
        link_text = 'the original'
        
      # Position and style the tag.
      tag = $('<div>From <a id="source_link" href="'+scrape_source+'">'+link_text+'</a><a id="home_link" href="http://fromthecache.com/">fromthecache.com</a></div>')
      tag.css 'position',         'absolute'
      tag.css 'top',              '5px'
      tag.css 'right',            '5px'
      tag.css 'background-color', '#AA0101'
      tag.css 'color',            '#fff'
      tag.css 'padding',          '5px'
      tag.css 'font-size',        '16px'
      tag.css 'font-weight',      'bold'
      link = tag.find 'a#source_link'
      link.css 'color',           '#fff'
      link.css 'text-decoration', 'underline'
      link.css 'font-size',       '16px'
      link.css 'font-weight',     'bold'
      link = tag.find 'a#home_link'
      link.css 'color',           '#fff'
      link.css 'text-decoration', 'none'
      link.css 'font-size',       '8px'
      link.css 'font-weight',     'normal'
      link.css 'display',         'block'
      link.css 'margin',          '0 auto'
      link.css 'text-align',      'center'
      $('body').append tag
    
  handle_search: ->
    form = $(this)
    if form.length > 0
      document.location.href = '/' + $('input#search_field').attr('value')
      return false
    
}

$(document).ready app.init