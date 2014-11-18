var streamsApp = angular.module('streamsApp', []);

streamsApp.controller('SessionCtrl', function ($scope, $http, $interval) {
  startPolling = function() {
    if (!$scope.promise)
      $scope.promise = $interval(getSessionAndPlaylists, 1500, 100)
  }

  cancelPolling = function() {
    if ($scope.promise)
      $interval.cancel($scope.promise);
  }

  getSessionAndPlaylists = function() {
    // get a valid session then playlists
    $http.get('session').
      success(function(data) {
        $scope.session = data;

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
        $scope.session    = null
        $scope.playlists  = null
        $scope.total      = 0
        $scope.processed  = 0
        $scope.matched    = 0
      });
  }

  getSessionAndPlaylists()
});
