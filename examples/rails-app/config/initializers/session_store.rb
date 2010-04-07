# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_rails-app_session',
  :secret      => '66585bee1616dfbbe5a91569aedea95fdac04f1df1a7a752f3c84afe741aefd779f16217b9e60f6180d8ba177a6aab9157dfb99792c1e6074a07cbbb63a862b2'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
