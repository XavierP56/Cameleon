# Copyright Xavier Pouyollon 2014
# GPL v3 License

app = angular.module 'myApp', ['ngResource','ui.router']

app.config ($stateProvider) ->
  room1 = {url: "/Room1", templateUrl: "/sceniq/room1.html",  controller: RoomCtrl}
  room2 = {url: "/Room2", templateUrl: "/sceniq/room2.html",  controller: RoomCtrl}
  $stateProvider.state('room1', room1)
  $stateProvider.state('room2', room2)

# Directive
app.directive 'fold', ->
  restrict : 'E'
  templateUrl : '/sceniq/fold.html'
  scope : {foldName : '@'}
  transclude : true

app.directive 'soundButton', ->
  restrict : 'E'
  scope : { songName : '@', id : '@', songFile : '@', height : '@', loop : '=?', defLevel : '=?'}

  controller: ($scope, $resource, $q) ->
    SoundPlay =  $resource('/sounds/play/:id',{},{do:{method:'POST'}})
    SoundStop =  $resource('/sounds/stop/:id')
    SoundLevel = $resource('/sounds/level/:id/:power')

    Query = $resource('/sounds/query/:id')
    $scope.loop = $scope.loop || false
    $scope.defLevel = $scope.defLevel || 100

    $scope.started = Query.get {id: $scope.id}, (res) ->
      $scope.playing = res.playing
      $scope.classstyle = 'playStyle' if $scope.playing == true
      $scope.classstyle = 'stopStyle' if $scope.playing == false
      snd = res.level if res.level?
      snd = $scope.defLevel if not res.level?
      $scope.power = snd

    $scope.playSong = () ->
       SoundPlay.do {id: $scope.id, repeat: $scope.loop, name:$scope.songFile, power:$scope.power}, ->
         return

    $scope.stopSong = () ->
      SoundStop.get {id: $scope.id}, ->
         return

    $scope.doit = () ->
      # Send request to server
      $scope.playSong() if $scope.playing == false
      $scope.stopSong() if $scope.playing == true

    $scope.level = () ->
      SoundLevel.get {id: $scope.id, power: $scope.power}, ->
        return

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

