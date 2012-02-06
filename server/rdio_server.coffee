root = exports ? this

rdio_api = require('rdio')

class root.RdioServer
  constructor: (api_key, shared_key, host) ->
    @rdio_api = rdio_api
      rdio_api_key: api_key
      rdio_api_shared: shared_key
      callback_url: "http://#{host}/oauth/callback"

  login: (callback=->) =>
    @rdio_api.getRequestToken (error, oauth_token, oauth_token_secret, results) =>
      @oauth_token = oauth_token
      @oauth_token_secret = oauth_token_secret
      if error
        throw new Error error
      else
        callback "https://www.rdio.com/oauth/authorize?oauth_token=#{oauth_token}"

  oauth_callback: (oauth_verifier, callback=->) =>
    @rdio_api.getAccessToken @oauth_token, @oauth_token_secret, oauth_verifier, (error, oauth_access_token, oauth_access_token_secret, results) =>
      @oauth_access_token = oauth_access_token
      @oauth_access_token_secret = oauth_access_token_secret
      callback()

  search: (query, callback=->) =>
    @rdio_api.api @oauth_access_token, @oauth_access_token_secret,
      method: 'search'
      types: "Track"
      query: query
      (error, data, response) =>
        callback data
