var streamsApp = angular.module('streamsApp', []);

streamsApp.controller('SessionCtrl', function ($scope, $http) {
  $http.get('session').
    success(function(data) {
      $scope.session = data;
    }).
    error(function(data, status, headers, config) {
      $scope.session = null;
    });
});

streamsApp.controller('PlaylistsCtrl', function ($scope, $http) {
  $http.get('playlists').success(function(data) {
    $scope.playlists = data;
  });
});

streamsApp.controller('TracksCtrl', function ($scope, $http) {
  $http.get('tracks').success(function(data) {
    $scope.tracms = data;
  });
});