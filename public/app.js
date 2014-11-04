var streamsApp = angular.module('streamsApp', []);

streamsApp.controller('AuthCtrl', function ($scope, $http) {
  $http.get('me').success(function(data) {
    console.log(data)
    $scope.me = data;
  });
});

streamsApp.controller('PlaylistCtrl', function ($scope, $http) {
  $http.get('playlists').success(function(data) {
    console.log(data)
    $scope.playlists = data;
  });
});