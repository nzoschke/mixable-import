
var streamsApp = angular.module('streamsApp', []);

streamsApp.controller('WorkflowCtrl', function ($scope, $filter, $http, $q, $timeout) {
  $scope.postImports = function() {
    $http.post("imports").
      success(function(data) {
        getImports()
      }).error(function(data, status, headers, config) {
        resetWorkflow()
      })
  }

  getRdioTrackProgress = function(rdio_playlists) {
    var deferred = $q.defer()
    var rdio_tracks = { total: 0, processed: 0, matched: 0 }

    angular.forEach(rdio_playlists, function(playlist, i) {
      rdio_tracks.total     += playlist.tracks.total
      rdio_tracks.processed += playlist.tracks.processed
      rdio_tracks.matched   += playlist.tracks.matched
    })

    // TODO: Move $scope.rdio_tracks update to setPlaylists .then()
    $scope.rdio_tracks = rdio_tracks

    if (rdio_tracks.total == rdio_tracks.processed) {
      deferred.resolve(rdio_tracks)
    } else {
      deferred.notify(rdio_tracks)

      $timeout(function() {
        $http.get("playlists/rdio").success(function(data, status, headers, config) {
          getRdioTrackProgress(data).then(deferred.resolve, deferred.reject, deferred.notify)
        })
      }, 1500)
    }

    return deferred.promise
  }

  _setPlaylists = function(results) {
    // Puts data in scope for view:
    // Raw API data:        rdio_playlists, spotify_playlist, imports
    // Polling results:     rdio_tracks
    // Import display data: rdio_spotify_playlists, import_playlists, other_spotify_playlists

    console.log("setPlaylists", results)
    var deferred = $q.defer()

    if ($scope.auth.rdio_username)
      $scope.rdio_playlists = results[0].data

    if ($scope.auth.spotify_username)
      $scope.spotify_playlists = results[1].data

    if ($scope.auth.rdio_username && $scope.auth.spotify_username)
      $scope.imports = results[2].data

    // Spotify import conflict display data
    if ($scope.spotify_playlists) {
      $scope.rdio_spotify_playlists   = $filter("filter")($scope.spotify_playlists, "Rdio ")
      $scope.other_spotify_playlists  = $filter("filter")($scope.spotify_playlists, "!Rdio ")

      if ($scope.rdio_playlists) {
        $scope.import_playlists = $scope.rdio_playlists
        $scope.import_playlist_names = $scope.import_playlists.map(function(p) {
          p.name = "Rdio / " + p.name
          return p.name
        })

        for (var i = $scope.spotify_playlists.length - 1; i >= 0; i--) {
          var p = $scope.spotify_playlists[i]

          // remove playlist object from spotify_playlists if name matches
          m = $scope.import_playlist_names.indexOf(p.name)
          if (m >= 0) {
            $scope.spotify_playlists.splice(i, 1)[0]
            $scope.import_playlists[m].overwrite = true
          }
        }
      }
    }

    // Poll Rdio track matching and Import playlist creation before resolving promise
    getRdioTrackProgress($scope.rdio_playlists).then(deferred.resolve)

    return deferred.promise
  }

  _reject = function(result) {
    console.log("REJECT", result)
  }

  getAuthPlaylists = function() {
    $http.get("auth").then(function(results) {
      $scope.auth = results.data

      $q.all([
        $http.get("playlists/rdio"),
        $http.get("playlists/spotify"),
        $http.get("imports")
      ]).then(_setPlaylists)
    }, _reject)
  }

  getAuthPlaylists()
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
