# Copyright Xavier Pouyollon 2014
# GPL v3 License

app = angular.module 'myApp', ['ngResource','ui.router']

app.config ($stateProvider) ->
  room1 = {url: "/Intro", templateUrl: "/sceniq/room1.html",  controller: RoomCtrl}

  $stateProvider.state('room1', room1)

# Directive
app.directive 'soundButton', ->
  restrict : 'E'
  scope : { songName : '@', id : '@', songFile : '@'}

  controller: ($scope, $resource, $q) ->
    SoundPlay =  $resource('/sounds/play/:id/:name')
    SoundStop =  $resource('/sounds/stop/:id')
    Query = $resource('/sounds/query/:id')

    $scope.started = Query.get {id: $scope.id}, (res) ->
      $scope.playing = res.res
      $scope.classstyle = 'playStyle' if $scope.playing == true
      $scope.classstyle = 'stopStyle' if $scope.playing == false

    $scope.playSong = () ->
       SoundPlay.get {id: $scope.id, name:$scope.songFile}, ->
         return

    $scope.stopSong = () ->
      SoundStop.get {id: $scope.id}, ->
         return

    $scope.doit = () ->
      # Send request to server
      $scope.playSong() if $scope.playing == false
      $scope.stopSong() if $scope.playing == true

    $scope.started.$promise.then () ->
      $scope.$on 'play', (sender, evt) ->
        if evt.id != $scope.id
          return
        $scope.playing = true
        $scope.classstyle = 'playStyle'

      $scope.$on 'stop', (sender, evt) ->
        if evt.id != $scope.id
          return
        $scope.playing = false
        $scope.classstyle = 'stopStyle'

  templateUrl : '/sceniq/soundbutton.html'

@RoomCtrl = ($scope, $http, $q, $resource)->
  Events = $resource('/sounds/events')
  Start = $resource('/sounds/starts')

  # Wait for event, analyze it and broadcast it.
  $scope.getEvent = () ->
    Events.get {}, (evt) ->
      $scope.$broadcast('play', evt) if evt.evt == 'play'
      $scope.$broadcast('stop', evt) if evt.evt == 'stop'
      $scope.getEvent()

  $scope.getEvent()

