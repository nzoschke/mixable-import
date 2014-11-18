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

          var total = 0, processed = 0;
          angular.forEach($scope.playlists, function(playlist, i) {
            total     += playlist.tracks.total
            processed += playlist.tracks.processed
          })

          // if all tracks are processed, cancel any polling, otherwise start polling
          if (total == processed)
            cancelPolling()
          else
            startPolling()
        });
      }).
      error(function(data, status, headers, config) {
        cancelPolling()
        $scope.session = null
        $scope.playlists = null
      });
  }

  getSessionAndPlaylists()
});
