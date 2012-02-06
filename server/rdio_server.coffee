root = exports ? this

rdio_api = require 'rdio'
exec = require("child_process").exec

{EventEmitter} = require 'events'

class root.RdioServer extends EventEmitter
  constructor: (@oauth_token_secret, @oauth_token_secret, api_key, shared_key, host) ->
    @rdio_api = rdio_api
      rdio_api_key: api_key
      rdio_api_shared: shared_key
      callback_url: "http://#{host}/oauth/callback"
    exec "google-chrome 'http://#{host}/rdio.html'"

  login: (callback=->) =>
    return if @oauth_token_secret and @oauth_token_secret
    @rdio_api.getRequestToken (error, @oauth_token, @oauth_token_secret, results) =>
      if error
        throw new Error error
      else
        callback "https://www.rdio.com/oauth/authorize?oauth_token=#{oauth_token}"

  oauth_callback: (oauth_verifier) =>
    @rdio_api.getAccessToken @oauth_token, @oauth_token_secret, oauth_verifier, (error, oauth_access_token, oauth_access_token_secret, results) =>
      @oauth_access_token = oauth_access_token
      @oauth_access_token_secret = oauth_access_token_secret
      @emit 'configchange'

  search: (query, callback=->) =>
    @rdio_api.api @oauth_access_token, @oauth_access_token_secret,
      method: 'search'
      types: "Track"
      query: query
      (error, data, response) =>
        callback data

  get_playback_token: (domain, callback) =>
    @rdio_api.api @oauth_access_token, @oauth_access_token_secret,
      method: 'getPlaybackToken'
      domain: domain
      (error, data, response) =>
        callback JSON.parse(data).result
