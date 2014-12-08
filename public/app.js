
var streamsApp = angular.module('streamsApp', []);

streamsApp.controller('WorkflowCtrl', function ($scope, $filter, $http, $q, $timeout) {
  $scope.postImports = function() {
    console.log("postImports")
    angular.forEach($filter("filter")($scope.spotify_playlists, "Rdio / "), function(p, i) {
      p.state = "pending"
    })

    $http.post("imports/spotify")
      .then(getAuthPlaylists)
  }

  getRdioProgress = function() {
    var deferred = $q.defer()
    var rdio_tracks = { total: 0, processed: 0, matched: 0 }

    angular.forEach($scope.rdio_playlists, function(playlist, i) {
      rdio_tracks.total     += playlist.tracks.total
      rdio_tracks.processed += playlist.tracks.processed
      rdio_tracks.matched   += playlist.tracks.matched
    })

    $scope.rdio_tracks = rdio_tracks

    if (rdio_tracks.total == rdio_tracks.processed) {
      deferred.resolve(rdio_tracks)
    } else {
      deferred.notify(rdio_tracks)

      $timeout(function() {
        $http.get("playlists/rdio").success(function(data, status, headers, config) {
          $scope.rdio_playlists = data
          getRdioProgress().then(deferred.resolve, deferred.reject, deferred.notify)
        })
      }, 1500)
    }

    return deferred.promise
  }

  getSyncedProgress = function() {
    var deferred = $q.defer()
    console.log("getSyncedProgress")

    // Determine sync state: unknown, update, create, synced

    angular.forEach($scope.spotify_playlists, function(p, i) {
      p.state = "unknown"
    })

    angular.forEach($scope.rdio_playlists, function(p, i) {
      p.state = "unknown"

      // only update playlists state if a valid spotify session
      if (!$scope.auth.spotify_username)
        return

      var sps = $filter("filter")($scope.spotify_playlists, "Rdio / " + p.name)
      if (sps.length == 0) {
        p.state = "create"
        if ($scope.auth.import_uuid)
          p.state = "pending"

        cp = JSON.parse(JSON.stringify(p))
        cp.name = "Rdio / " + p.name
        cp.tracks.total = 0
        $scope.spotify_playlists.push(cp)

      }
      else {
        var sp = sps[0]
        p.state = p.tracks.matched == sp.tracks.total ? "skip" : "update"
        if ($scope.auth.import_uuid)
          p.state = "pending"

        sp.state = p.state
        sp.tracks.matched = p.tracks.total
      }

    })

    $scope.spotify_rdio_playlists = $filter("filter")($scope.spotify_playlists, "Rdio / ")

    if ($scope.spotify_imports.length > 0) {
      if (!$scope.auth.import_uuid)
        return

      $scope.synced_playlists = $scope.spotify_imports[0].playlists

      angular.forEach($scope.synced_playlists.items, function(p, i) {
        angular.forEach($filter("filter")($scope.rdio_playlists, p.name.replace("Rdio / ", "")), function(rp, i) {
          rp.state = "done"
        })

        angular.forEach($filter("filter")($scope.spotify_playlists, p.name), function(sp, i) {
          sp.state = "done"
          sp.tracks.total = p.tracks.total
        })
      })

      if ($scope.synced_playlists.processed >= $scope.synced_playlists.total)
        deferred.resolve()
      else {
        deferred.notify()

        $timeout(function() {
          $http.get("imports/spotify").success(function(data, status, headers, config) {
            $scope.spotify_imports = data
            getSyncedProgress(data).then(deferred.resolve, deferred.reject, deferred.notify)
          })
        }, 1500)
      }
    }
    else deferred.resolve()

    return deferred.promise
  }

  setPlaylists = function(results) {
    var deferred = $q.defer()

    $scope.rdio_playlists     = results[0].data
    $scope.spotify_playlists  = results[1].data
    $scope.spotify_imports    = results[2].data

    // Poll Rdio track matching and Import playlist creation before resolving promise
    getRdioProgress()
      .then(getSyncedProgress)
      .then(deferred.resolve)

    return deferred.promise
  }

  reject = function(result) {
    console.log("REJECT", result)
  }

  getAuthPlaylists = function() {
    $http.get("auth").then(function(results) {
      $scope.auth = results.data

      $q.all([
        $http.get("playlists/rdio"),
        $http.get("playlists/spotify"),
        $http.get("imports/spotify")
      ]).then(setPlaylists)
    }, reject)
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
