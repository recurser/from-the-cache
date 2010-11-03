require 'spec_helper'

describe Search do
  
  # Make sure the cache is clear.    
  before(:each) do
    Rails.cache.clear
    # Try to avoid getting blocked by google.
    sleep 1
  end

  it 'should fix URLs with a single forward-slash' do
    search     = Search.new
    search.url = 'http:/google.com'
    search.url.should == 'http://google.com'
  end

  it 'should handle URLs without a http prefix' do
    search     = Search.new
    search.url = 'google.com'
    search.result[:content].should include('<title>Google</title>')
  end

  it 'should cache search results' do
    search     = Search.new
    search.url = 'http://google.com'
    search.result[:content].should == Rails.cache.read(search.url)[:content]
  end

  it 'should return nil for impossible requests' do
    search     = Search.new
    search.url = 'http://imposs.ible'
    search.result.should == nil
  end

  it 'should save __nil__ in the cache for impossible requests' do
    search     = Search.new
    search.url = 'http://imposs.ible'
    search.result
    Rails.cache.read(search.url).should == '__nil__'
    search.result.should == nil
  end

  it 'should return nil for cached impossible requests' do
    search     = Search.new
    search.url = 'http://imposs.ible'
    search.result
    search.result.should == nil
  end

  it 'should add a <base> tag' do
    search     = Search.new
    search.url = 'http://google.com'
    search.result[:content].should include( "<base href=\"#{search.url}\" />")
  end

  it 'should remove google cache headers' do
    search     = Search.new
    search.url = 'http://google.com'
    # TODO
  end

  it 'should retrieve URLs we know are not cached' do
    search     = Search.new
    search.url = 'news.ycombinator.com/item?id=4'
    search.result[:content].should include('<title>Hacker News | NYC Developer Dilemma</title>')
    search.result[:content].should include('<input id="scrape_source" value="http%3A%2F%2Fnews.ycombinator.com%2Fitem%3Fid%3D4" type="hidden" />')
  end

  it 'should append a javascript tag' do
    search     = Search.new
    search.url = 'http://google.com'
    search.result[:content].should include('<script src="http://fromthecache.com/assets/common.js"></script>')
  end

  it 'should handle timeouts' do
    search     = Search.new
    search.url = 'hello.com'
    search.result.should == nil
  end

  it 'should handle http -> https redirects' do
    # http gmail redirects to https automatically. This tests the OpenURI
    # monkey-patch in the Search model.
    search     = Search.new
    search.url = 'http://gmail.com/'
    search.result[:content].should include("<title>\n  Gmail: Email from Google\n</title>")
  end
  
  
end