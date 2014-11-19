var streamsApp = angular.module('streamsApp', []);

streamsApp.controller('SessionCtrl', function ($scope, $http, $interval) {
  $scope.toPad = function(playlist) {
    s = ""
    for (var i = 0; i < playlist.tracks.items.length; i++) {
      var track = playlist.tracks.items[i]
      s += track.name + " @" + track.artists[0].name + " [" + track.album.name + "]\n"
      s += "  #" + track.external_ids.isrc + "\n"
    }
    return s
  }

  $scope.submit = function() {
  }

  startPolling = function() {
    if (!$scope.promise)
      $scope.promise = $interval(getRdioPlaylists, 1500, 100)
  }

  cancelPolling = function() {
    if ($scope.promise)
      $interval.cancel($scope.promise)
  }

  getAuth = function() {
    $http.get('auth').
      success(function(data) {
        $scope.auth = data;

        if ($scope.auth.rdio_username)
          getRdioPlaylists()

        if ($scope.auth.spotify_username)
          getSpotifyPlaylists()
      }).
      error(function(data, status, headers, config) {
        cancelPolling()
        $scope.auth                 = null
        $scope.rdio_playlists       = null
        $scope.spotify_playlists    = null
        $scope.total                = 0
        $scope.processed            = 0
        $scope.matched              = 0
      })
  }

  getRdioPlaylists = function() {
    $http.get('playlists').
      success(function(data) {
        $scope.rdio_playlists = data

        $scope.total      = 0
        $scope.processed  = 0
        $scope.matched    = 0

        angular.forEach($scope.rdio_playlists, function(playlist, i) {
          $scope.total     += playlist.tracks.total
          $scope.processed += playlist.tracks.processed
          $scope.matched   += playlist.tracks.matched
        })

        if ($scope.total == $scope.processed)
          cancelPolling()
        else
          startPolling()
      }).error(function(data, status, headers, config) {
        cancelPolling()
        $scope.rdio_playlists   = null
        $scope.total            = 0
        $scope.processed        = 0
        $scope.matched          = 0
      })
  }

  getSpotifyPlaylists = function() {
    $http.get('playlists?spotify=true').
      success(function(data) {
        $scope.spotify_playlists = data
      }).error(function(data, status, headers, config) {

      })
  }

  getAuth()
});
