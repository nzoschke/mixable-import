
var streamsApp = angular.module('streamsApp', []);

streamsApp.controller('WorkflowCtrl', function ($scope, $http, $interval) {

  $scope.flows = ["rdio_username", "rdio_playlists", "spotify_username", "spotify_playlists", "spotify_imports"]

  $scope.nextWorkflow = function() {
    for (var i = 0; i < $scope.flows.length; i++) {
      var flow = $scope.flows[i]
      if (!$scope[flow])
        return flow
    }
    return null
  }

  resetWorkflow = function() {
    $scope.rdio_username      = null
    $scope.rdio_playlists     = null
    $scope.spotify_username   = null
    $scope.spotify_playlists  = null
    $scope.spotify_imports    = null
  }

  doWorkflow = function() {
    getRdioUsername()
    getRdioPlaylists()
    getSpotifyUsername()
    getSpotifyPlaylists()
    getSpotifyImports()
  }

  getRdioUsername = function() {
    if ($scope.nextWorkflow() != "rdio_username")
      return false

    $http.get('auth').
      success(function(data) {
        if (!data.rdio_username)
          return

        $scope.rdio_username = data.rdio_username
        doWorkflow()
      }).
      error(function(data, status, headers, config) {
        resetWorkflow()
      })
  }

  getRdioPlaylists = function() {
    if ($scope.nextWorkflow() != "rdio_playlists")
      return false

    $http.get('playlists').
      success(function(data) {
        $scope.rdio_playlists                   = data
        $scope.rdio_playlists.tracks_total      = 0
        $scope.rdio_playlists.tracks_processed  = 0
        $scope.rdio_playlists.tracks_matched    = 0

        angular.forEach($scope.rdio_playlists, function(playlist, i) {
          $scope.rdio_playlists.tracks_total     += playlist.tracks.total
          $scope.rdio_playlists.tracks_processed += playlist.tracks.processed
          $scope.rdio_playlists.tracks_matched   += playlist.tracks.matched
        })

        doWorkflow()
      }).error(function(data, status, headers, config) {
        resetWorkflow()
      })
  }

  getSpotifyUsername = function() {
    if ($scope.nextWorkflow() != "spotify_username")
      return false

    $http.get('auth').
      success(function(data) {
        if (!data.spotify_username)
          return

        $scope.spotify_username = data.spotify_username
        doWorkflow()
      }).
      error(function(data, status, headers, config) {
        resetWorkflow()
      })
  }

  getSpotifyPlaylists = function() {
    if ($scope.nextWorkflow() != "spotify_playlists")
      return false

    $http.get('playlists?spotify=true').
      success(function(data) {
        $scope.spotify_playlists = data
        doWorkflow()
      }).error(function(data, status, headers, config) {
        resetWorkflow()
      })
  }

  getSpotifyImports = function() {
    if ($scope.nextWorkflow() != "spotify_imports")
      return false

    $http.get('imports').
      success(function(data) {
        $scope.spotify_imports = data
        doWorkflow()
      }).error(function(data, status, headers, config) {
        resetWorkflow()
      })
  }

  $scope.spotifyImportName = function(rp_name) {
    return "Rdio / " + rp_name
  }

  $scope.conflicts = function(rp_name) {
    if (!$scope.spotify_playlists)
      return false

    for (var i = 0; i < $scope.spotify_playlists.items.length; i++) {
      var sp = $scope.spotify_playlists.items[i]
      if (sp.name == $scope.spotifyImportName(rp_name))
        return true
    }
    return false
  }

  resetWorkflow()
  doWorkflow()
})
