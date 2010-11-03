require 'spec_helper'

describe PagesController do
  
  render_views

  describe 'GET *search*' do
    
    it 'should be successful' do
      get :search
      response.should be_success
    end
    
    it 'should have the correct title' do
      get :search
      response.should have_selector('title', :content => I18n.t('pages.search.title'))
    end

    it 'should remove initial http from searches' do
      get :search, :url => 'http://google.com/'
      response.should redirect_to('/google.com/')
    end

    it 'should return an error for invalid domains' do
      get :search, :url => 'invalid'
      msg = I18n.t('pages.search.invalid_url_warning')
      flash.now[:alert].should == msg
    end

    it 'should return a 404 for non-existent domains' do
      url = '123-hopefully-no-one-will-ever-register-this-domain-456.com'
      get :search, :url => url
      response.should be_missing
      response.body.should include(I18n.t('pages.error.heading'))
      response.body.should include(url)
    end

    it 'should return the correct content-type' do
      get :search, :url => '/google.com/'
      response.content_type.should == 'text/html'
      get :search, :url => 'www.google.com/intl/en_ALL/images/srpr/logo1w.png'
      response.content_type.should == 'image/png'
    end
  end

  describe 'GET *about*' do
    it 'should be successful' do
      get :about
      response.should be_success
    end
    
    it 'should have the correct title' do
      get :about
      response.should have_selector('title', :content => I18n.t('pages.about.title'))
    end
  end

end
