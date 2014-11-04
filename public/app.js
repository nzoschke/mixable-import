var phonecatApp = angular.module('phonecatApp', []);

phonecatApp.controller('AuthCtrl', function ($scope, $http) {
  $http.get('me').success(function(data) {
    console.log(data)
    $scope.me = data;
  });
});