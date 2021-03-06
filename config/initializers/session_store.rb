# Be sure to restart your server when you modify this file.

#FromTheCache::Application.config.session_store :cookie_store, :key => '_from_the_cache'

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# FromTheCache::Application.config.session_store :active_record_store

require 'action_dispatch/middleware/session/dalli_store'
Rails.application.config.session_store :dalli_store, :namespace => 'sessions', :key => '_from_the_cache_session', :expire_after => 30.minutes