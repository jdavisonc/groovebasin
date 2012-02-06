unique = (array) ->
  output = {}
  output[element] = [element] for element in array
  value for key, value of output

window.RdioClient = class RdioClient
  constructor: ->
    @search_results =
      artist_list: []

  search: (query) ->
    @search_callback query

  handleSearchResults: (search_results) ->
    results = JSON.parse(search_results).result.results

    artists = {}
    for result in results
      artists[result.artist] ||= {name: result.artist, albums: {}}
      artists[result.artist]['albums'][result.album] ||= {name: result.album, tracks: {}}
      artists[result.artist]['albums'][result.album]['tracks'][result.url] = {name: result.name, track: result.trackNum, time: result.duration, url: result.url}

    @search_results.artist_list = (artist for artist_name, artist of artists)
    @search_results_callback()

  onSearch: (@search_callback=->) ->
  onSearchResults: (@search_results_callback=->) ->
