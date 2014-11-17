var streamsApp = angular.module('streamsApp', []);

streamsApp.controller('SessionCtrl', function ($scope, $http, $interval) {
  $scope.startPolling = function() {
    if (!$scope.promise)
      $scope.promise = $interval($scope.getSessionAndPlaylists, 1500, 100)
  }

  $scope.cancelPolling = function() {
    if ($scope.promise)
      $interval.cancel($scope.promise);
  }

  $scope.getSessionAndPlaylists = function() {
    // get a valid session then playlists
    $http.get('session').
      success(function(data) {
        $scope.session = data;

        $http.get('playlists').success(function(data) {
          $scope.playlists = data;

          // if all tracks are processed, cancel any polling, otherwise start polling
          if ($scope.session.tracks_processed == $scope.session.tracks_total)
            $scope.cancelPolling()
          else
            $scope.startPolling()
        });
      }).
      error(function(data, status, headers, config) {
        if ($scope.promise)
          $interval.cancel($scope.promise);

        $scope.session = null;
        $scope.playlists = null;
      });
  }

  $scope.getSessionAndPlaylists()
});
