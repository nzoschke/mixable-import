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
      $scope.promise = $interval(getAuthAndPlaylists, 1500, 100)
  }

  cancelPolling = function() {
    if ($scope.promise)
      $interval.cancel($scope.promise);
  }

  getAuthAndPlaylists = function() {
    // get a valid auth then playlists
    $http.get('auth').
      success(function(data) {
        $scope.auth = data;

        $http.get('playlists').success(function(data) {
          $scope.playlists = data

          $scope.total      = 0
          $scope.processed  = 0
          $scope.matched    = 0

          angular.forEach($scope.playlists, function(playlist, i) {
            $scope.total     += playlist.tracks.total
            $scope.processed += playlist.tracks.processed
            $scope.matched   += playlist.tracks.matched
        })

          // if all tracks are processed, cancel any polling, otherwise start polling
          if ($scope.total == $scope.processed)
            cancelPolling()
          else
            startPolling()
        });
      }).
      error(function(data, status, headers, config) {
        cancelPolling()
        $scope.auth    = null
        $scope.playlists  = null
        $scope.total      = 0
        $scope.processed  = 0
        $scope.matched    = 0
      });
  }

  getAuthAndPlaylists()
});
