var LastFmNode = require('lastfm').LastFmNode;

module.exports = LastFm;

function LastFm(gb) {
  this.gb = gb;

  this.previousNowPlayingId = null;
  this.lastPlayingItem = null;
  this.playingStart = new Date();
  this.playingTime = 0;
  this.previousPlayState = null;
  this.scrobblers = {};
  this.scrobbles = [];
  this.lastfm = new LastFmNode({
    api_key: this.gb.config.lastfmApiKey,
    secret: this.gb.config.lastfmApiSecret,
  });
  this.gb.on('socketConnect', onSocketConnection.bind(this));
}

LastFm.prototype.initialize = function(cb) {
  var self = this;

  self.gb.db.get('Plugin.lastfm', function(err, value) {
    if (err) {
      if (err.type !== 'NotFoundError') {
        return cb(err);
      }
    } else {
      var state = JSON.parse(value);
      self.scrobblers = state.scrobblers;
      self.scrobbles = state.scrobbles;
    }
    // in case scrobbling fails and then the user presses stop, this will still
    // flush the queue.
    setInterval(flushScrobbleQueue.bind(self), 120000);
    cb();
  });
};

LastFm.prototype.persist = function() {
  var self = this;
  var state = {
    scrobblers: self.scrobblers,
    scrobbles: self.scrobbles,
  };
  self.gb.db.put('Plugin.lastfm', JSON.stringify(state), function(err) {
    if (err) {
      console.error("Error persisting lastfm to db:", err.stack);
    }
  });
};


function onSocketConnection(socket) {
  var self = this;
  socket.on('LastfmGetSession', function(data){
    self.lastfm.request("auth.getSession", {
      token: data,
      handlers: {
        success: function(data){
          var ref$;
          delete self.scrobblers[data != null ? (ref$ = data.session) != null ? ref$.name : void 8 : void 8];
          socket.emit('LastfmGetSessionSuccess', JSON.stringify(data));
        },
        error: function(error){
          console.error("error from last.fm auth.getSession: " + error.message);
          socket.emit('LastfmGetSessionError', JSON.stringify(error));
        }
      }
    });
  });
  socket.on('LastfmScrobblersAdd', function(data){
    var params;
    params = JSON.parse(data);
    if (self.scrobblers[params.username] != null) {
      return;
    }
    self.scrobblers[params.username] = params.session_key;
    self.persist();
  });
  socket.on('LastfmScrobblersRemove', function(data){
    var params = JSON.parse(data);
    var session_key = self.scrobblers[params.username];
    if (session_key === params.session_key) {
      delete self.scrobblers[params.username];
      self.persist();
    } else {
      console.warn("Invalid session key from user trying to remove scrobbler: " + params.username);
    }
  });
  socket.emit('LastfmApiKey', self.apiKey);
};

function flushScrobbleQueue() {
  var self = this;
  var params;
  var max_simultaneous = 10;
  var count = 0;
  while ((params = self.scrobbles.shift()) != null && count++ < max_simultaneous) {
    console.info("scrobbling " + params.track + " for session " + params.sk);
    params.handlers = {
      error: fn$
    };
    self.lastfm.request('track.scrobble', params);
  }
  self.persist();
  function fn$(error){
    console.error("error from last.fm track.scrobble: " + error.message);
    if ((error != null ? error.code : void 8) == null || error.code === 11 || error.code === 16) {
      self.scrobbles.push(params);
      self.persist();
    }
  }
};

LastFm.prototype.queueScrobble = function(params){
  this.scrobbles.push(params);
  this.persist();
};

LastFm.prototype.checkTrackNumber = function(trackNumber){
  if (parseInt(trackNumber, 10) >= 0) {
    return trackNumber;
  } else {
    return "";
  }
};

LastFm.prototype.checkScrobble = function(){
  var self = this;
  
  var curItem = 
};

LastFm.prototype.updateNowPlaying = function(){
  // TODO: implement
};

