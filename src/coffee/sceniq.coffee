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
  templateUrl : '/sceniq/templates/fold.html'
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
  templateUrl : '/sceniq/templates/dmxentry.html'
  scope : {id : '@', show:'='}
  controller: ($scope, $resource) ->
    Query = $resource('/dmx/getdefs/:id')
    Update = $resource('/dmx/setdefs', {}, {set:{method:'POST'}})

    Query.get {id: $scope.id}, (res) ->
      $scope.entries = res.res
      return

    $scope.update = () ->
      Update.set {'id': $scope.id, 'entries':$scope.entries}, ()->
        alert('Channels updated !')
      return

app.directive "dmxSlider", ->
  restrict : 'E'
  templateUrl : '/sceniq/templates/dmxslider.html'
  scope : {id : '@', key:'@', def:'@', name:'@'}
  controller: ($scope, $resource) ->
    Query = $resource('/dmx/query/:id/:key')
    DmxSet = $resource('/dmx/set', {}, {set:{method:'POST'}})

    $scope.started = Query.get {id: $scope.id, key: $scope.key}, (res) ->
        $scope.value = res[$scope.key]
        $scope.send()

    $scope.send = () ->
      cmd = {}
      cmd[$scope.key] = $scope.value
      DmxSet.set {id:$scope.id, cmds: cmd}, ->
        return

    $scope.$on 'update', (sender, evt) ->
        if (evt.id != $scope.id) or (evt.key != $scope.key)
          return
        $scope.value = evt.val

app.directive "dmxLight", ->
  restrict : 'E'
  templateUrl : '/sceniq/templates/dmxlight.html'
  scope : {id:'@', preset:'@'}
  transclude : true

  controller: ($scope, $resource) ->
    $scope.cmds = {}
    $scope.DmxSet =  $resource('/dmx/set',{},{set:{method:'POST'}})
    this.provide = (k,v) ->
      $scope.cmds[k] = v

    $scope.light = () ->
      $scope.DmxSet.set {id:$scope.id, cmds:$scope.cmds}, ->
        return

    return

app.directive "dmxValue", ->
  restrict : 'E'
  require: '^dmxLight'
  scope : { 'key' : '@', 'value' : '@'}

  link: (scope, element, attrs, dmxLightCtrl) ->
    dmxLightCtrl.provide(attrs.key,attrs.value)

app.directive "soundButton", ->
  restrict : 'E'
  scope : { songName : '@', id : '@', songFile : '@', height : '@', loop : '=?', defLevel : '=?'}
  templateUrl : '/sceniq/templates/soundbutton.html'

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
        $scope.$parent.$$prevSibling.$emit('foldplay') if $scope.$parent.$$prevSibling != null

      $scope.$on 'stop', (sender, evt) ->
        if evt.id != $scope.id
          return
        $scope.playing = false
        $scope.classstyle = 'stopStyle'
        $scope.$parent.$$prevSibling.$emit('foldstop') if $scope.$parent.$$prevSibling != null


@RoomCtrl = ($scope, $http, $q, $resource)->
  Events = $resource('/sounds/events')
  DmxEvents = $resource('/dmx/events')

  $scope.transition = () ->
    DmxTransition = $resource('/dmx/transition',{},{do:{method:'POST'}})

    DmxTransition.do {delay:2, id:'1', cmds: {'red':0, 'green':0, 'blue':0, 'dimmer':0}},  ->
      return

  # Wait for sound event, analyze it and broadcast it.
  $scope.getSoundEvent = () ->
    Events.get {}, (evt) ->
      $scope.$broadcast(evt.evt, evt)
      $scope.getSoundEvent()

  # Wait DMX events,  analyze it and broadcast it.
  $scope.getDmxEvent = () ->
    DmxEvents.get {}, (evt) ->
      $scope.$broadcast(evt.evt, evt)
      $scope.getDmxEvent()

  # Trigger them
  $scope.getSoundEvent()
  $scope.getDmxEvent()
