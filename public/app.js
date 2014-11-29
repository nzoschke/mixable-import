
var streamsApp = angular.module('streamsApp', []);

streamsApp.controller('WorkflowCtrl', function ($scope, $http, $timeout) {
  resetWorkflow = function() {
    if ($scope.rdio_timeout)
      $timeout.cancel($scope.rdio_timeout)

    if ($scope.spotify_timeout)
      $timeout.cancel($scope.spotify_timeout)

    if ($scope.imports_timeout)
      $timeout.cancel($scope.imports_timeout)

    $scope.rdio_username      = null
    $scope.rdio_playlists     = null
    $scope.rdio_tracks        = null
    $scope.rdio_timeout       = null

    $scope.spotify_username   = null
    $scope.spotify_playlists  = null
    $scope.spotify_tracks     = null
    $scope.spotify_timeout    = null

    $scope.imports            = null
    $scope.imports_timeout    = null
  }

  getUsernames = function(cb) {
    $http.get('auth').
      success(function(data) {
        $scope.rdio_username    = data.rdio_username
        $scope.spotify_username = data.spotify_username
        cb()
      }).
      error(function(data, status, headers, config) {
        resetWorkflow()
      })
  }

  getRdioPlaylists = function() {
    if (!$scope.rdio_username)
      return

    $http.get("playlists/rdio").
      success(function(data) {
        $scope.rdio_playlists = data
        $scope.rdio_tracks    = { total: 0, processed: 0, matched: 0}

        angular.forEach($scope.rdio_playlists, function(playlist, i) {
          $scope.rdio_tracks.total     += playlist.tracks.total
          $scope.rdio_tracks.processed += playlist.tracks.processed
          $scope.rdio_tracks.matched   += playlist.tracks.matched
        })

        if ($scope.rdio_tracks.total == $scope.rdio_tracks.processed) {
          if ($scope.rdio_timeout)
            $timeout.cancel($scope.rdio_timeout)
        }
        else
          $scope.rdio_timeout = $timeout(getRdioPlaylists, 1500)
      }).error(function(data, status, headers, config) {
        resetWorkflow()
      })
  }

  getSpotifyPlaylists = function() {
    if (!$scope.spotify_username)
      return

    $http.get("playlists/spotify").
      success(function(data) {
        $scope.spotify_playlists = data
        $scope.spotify_tracks    = { total: 0, processed: 0, matched: 0}

        angular.forEach($scope.spotify_playlists, function(playlist, i) {
          $scope.spotify_tracks.total     += playlist.tracks.total
          $scope.spotify_tracks.processed += playlist.tracks.processed
          $scope.spotify_tracks.matched   += playlist.tracks.matched
        })

        if ($scope.spotify_tracks.total == $scope.spotify_tracks.processed) {
          if ($scope.spotify_timeout)
            $timeout.cancel($scope.spotify_timeout)
        }
        else
          $scope.spotify_timeout = $timeout(getSpotifyPlaylists, 1500)
      }).error(function(data, status, headers, config) {
        resetWorkflow()
      })
  }

  getImports = function() {
    if (!$scope.rdio_username || !$scope.spotify_username)
      return

    $http.get("imports").
      success(function(data) {
        if (!data)
          return

        $scope.imports = data

        if ($scope.imports.total == $scope.imports.processed) {
          if ($scope.imports_timeout)
            $timeout.cancel($scope.imports_timeout)
        }
        else
          $scope.imports_timeout = $timeout(getImports, 1500)
      }).error(function(data, status, headers, config) {
        resetWorkflow()
      })
  }

  $scope.postImports = function() {
    $http.post("imports").
      success(function(data) {
        getImports()
      }).error(function(data, status, headers, config) {
        resetWorkflow()
      })
  }

  $scope.conflicts = function(list) {
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
  getUsernames(function() {
    getRdioPlaylists()
    getSpotifyPlaylists()
    getImports()
  })
})

$(function () {
  // Link to a tab
  var url = document.location.toString();
  if (url.match('#')) {
    $('.nav-tabs a[href=#'+url.split('#')[1]+']').tab('show')
  }

  // Change hash for page-reload
  $('.nav-tabs a').on('shown.bs.tab', function (e) {
    window.location.hash = e.target.hash
  })
})
