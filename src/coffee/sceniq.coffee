# Copyright Xavier Pouyollon 2014
# GPL v3 License

app = angular.module 'myApp', ['ngResource','ui.router']

app.config ($stateProvider) ->
  room1 = {url: "/Room1", templateUrl: "/sceniq/room1.html",  controller: RoomCtrl}
  room2 = {url: "/Room2", templateUrl: "/sceniq/room2.html",  controller: RoomCtrl}
  $stateProvider.state('room1', room1)
  $stateProvider.state('room2', room2)

# Directive
app.directive "fold", ->
  restrict : 'E'
  templateUrl : '/sceniq/fold.html'
  scope : {foldName : '@'}
  transclude : true
  controller: ($scope) ->
      $scope.nb = 0

      $scope.$on 'foldplay', (sender, evt) ->
        $scope.nb = $scope.nb + 1

      $scope.$on 'foldstop', (sender, evt) ->
        $scope.nb = $scope.nb - 1

app.directive "dmxEntry", ->
  restrict : 'E'
  scope : {id : '@', model: '@', channel: '@'}
  controller: ($scope, $resource) ->
    DmxEntry =  $resource('/dmx/entry',{},{add:{method:'POST'}})

    DmxEntry.add {id:$scope.id, model:$scope.model, channel:$scope.channel}, ->
      return

app.directive "dmxFader", ->
  restrict : 'E'
  templateUrl : '/sceniq/dmxfader.html'
  scope : {id : '@', model: '@'}
  controller: ($scope, $resource) ->
    Query = $resource('/dmx/query/:id')
    Values = $resource('/dmx/set', {}, {set:{method:'POST'}})

    $scope.started = Query.get {id: $scope.id}, (res) ->
      $scope.dmx = res

    $scope.send = (what) ->
      v = {}
      v[what] = $scope.dmx.power if what == 'power'
      v[what] = $scope.dmx.red if what == 'red'
      v[what] = $scope.dmx.green if what == 'green'
      v[what] = $scope.dmx.green if what == 'blue'
      Values.set {id:$scope.id, values: v}

app.directive "soundButton", ->
  restrict : 'E'
  scope : { songName : '@', id : '@', songFile : '@', height : '@', loop : '=?', defLevel : '=?'}
  templateUrl : '/sceniq/soundbutton.html'

  controller: ($scope, $resource) ->
    SoundPlay =  $resource('/sounds/play',{},{do:{method:'POST'}})
    SoundStop =  $resource('/sounds/stop/:id')
    SoundLevel = $resource('/sounds/level/:id/:power')
    Query = $resource('/sounds/query/:id')

    $scope.loop = $scope.loop || false
    $scope.defLevel = $scope.defLevel || 100

    $scope.started = Query.get {id: $scope.id}, (res) ->
      $scope.playing = res.playing
      $scope.classstyle = 'playStyle' if $scope.playing == true
      # When we are here, fold has been constructed and set to 0.
      $scope.$parent.$$prevSibling.$emit('foldplay') if $scope.playing == true
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
        $scope.$parent.$$prevSibling.$emit('foldplay')

      $scope.$on 'stop', (sender, evt) ->
        if evt.id != $scope.id
          return
        $scope.playing = false
        $scope.classstyle = 'stopStyle'
        $scope.$parent.$$prevSibling.$emit('foldstop')


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

