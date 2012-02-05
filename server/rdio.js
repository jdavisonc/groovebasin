(function() {
  var root;

  root = typeof exports !== "undefined" && exports !== null ? exports : this;

  root.Rdio = (function() {

    function Rdio(api_key) {
      this.api_key = api_key;
    }

    Rdio.prototype.search = function(query, callback) {
      return console.log(query);
    };

    return Rdio;

  })();

}).call(this);
