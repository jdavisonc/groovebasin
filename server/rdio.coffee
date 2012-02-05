root = exports ? this

class root.Rdio
  constructor: (@api_key) ->

  search: (query, callback) ->
    console.log query
