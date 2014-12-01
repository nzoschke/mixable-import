
var streamsApp = angular.module('streamsApp', []);

streamsApp.controller('WorkflowCtrl', function ($scope, $filter, $http, $timeout) {
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

  getRdioPlaylists = function(cb) {
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
        cb()
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

        $scope.import_spotify_playlists = []
        $scope.rdio_spotify_playlists   = []
        $scope.other_spotify_playlists  = []

        // Put Rdio playlists into new Spotify collection
        import_playlist_names = []
        for (var i = 0; i < $scope.rdio_playlists.length; i++) {
          var p = $scope.rdio_playlists[i]
          p.name = "Rdio / " + p.name
          import_playlist_names.push(p.name)
          $scope.import_spotify_playlists.push(p)
        }

        // Filter existing Spotify playlists into Spotify collections
        for (var i = 0; i < $scope.spotify_playlists.length; i++) {
          var p = $scope.spotify_playlists[i]

          m = import_playlist_names.indexOf(p.name)
          if (m >= 0) {
            console.log(m)
            $scope.import_spotify_playlists[m].overwrite = true
            continue
          }

          if (p.name.indexOf("Rdio ") == 0)
            $scope.rdio_spotify_playlists.push(p)
          else
            $scope.other_spotify_playlists.push(p)
        }
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

  resetWorkflow()
  getUsernames(function() {
    getRdioPlaylists(function() {
      getSpotifyPlaylists()
      getImports()      
    })
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
    window.scrollTo(0, 0)
  })
})
