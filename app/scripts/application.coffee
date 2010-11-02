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
      tag.css 'font-family',      'helvetica neue, arial, sans-serif !important'
      tag.css 'position',         'absolute !important'
      tag.css 'top',              '5px !important'
      tag.css 'right',            '5px !important'
      tag.css 'background-color', '#AA0101 !important'
      tag.css 'color',            '#fff !important'
      tag.css 'padding',          '5px !important'
      tag.css 'font-size',        '16px !important'
      tag.css 'font-weight',      'bold !important'
      
      link = tag.find 'a#source_link'
      tag.css 'font-family',      'helvetica neue, arial, sans-serif !important'
      link.css 'color',           '#fff !important'
      link.css 'text-decoration', 'underline !important'
      link.css 'font-size',       '16px !important'
      link.css 'font-weight',     'bold !important'
      
      link = tag.find 'a#home_link'
      tag.css 'font-family',      'helvetica neue, arial, sans-serif !important'
      link.css 'color',           '#fff !important'
      link.css 'text-decoration', 'none !important'
      link.css 'font-size',       '10px !important'
      link.css 'font-weight',     'normal !important'
      link.css 'display',         'block !important'
      link.css 'margin',          '0 auto !important'
      link.css 'text-align',      'center !important'
      $('body').append tag
    
  handle_search: ->
    form = $(this)
    if form.length > 0
      document.location.href = '/' + $('input#search_field').attr('value')
      return false
    
}

$(document).ready app.init