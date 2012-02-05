window.RdioClient = class _
  search: (query) ->
    @searchCallback query
  onSearch: (callback) ->
    @searchCallback = callback
