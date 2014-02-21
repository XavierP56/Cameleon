# Copyright Xavier Pouyollon 2014
# GPL v3 License

app = angular.module 'myApp', ['ngResource','ui.router','JSONedit']

app.config ($stateProvider) ->
  room1 = {url: "/Room1", templateUrl: "/sceniq/room1.html",  controller: RoomCtrl}
  room2 = {url: "/Room2", templateUrl: "/sceniq/room2.html",  controller: RoomCtrl}
  config = {url: "/Config", templateUrl: "/sceniq/config.html", controller: ConfigCtrl}
  $stateProvider.state('room1', room1)
  $stateProvider.state('room2', room2)
  $stateProvider.state('config', config)

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
  scope : {id:'@', preset:'@', transition:'=?', 'delay':'@', setting:'@'}
  transclude : true

  controller: ($scope, $resource) ->
    $scope.transition = $scope.transition || false
    $scope.dmxstyle='dmx' if $scope.transition == false
    $scope.dmxstyle='transit' if $scope.transition == true
    $scope.DmxSet =  $resource('/dmx/set',{},{set:{method:'POST'}})

    $scope.light = () ->
      $scope.DmxSet.set {id:$scope.id, setting:$scope.setting, transition:$scope.transition, delay:$scope.delay}, ->
        return

    return

app.directive "soundButton", ->
  restrict : 'E'
  scope : { id : '@'}
  templateUrl : '/sceniq/templates/soundbutton.html'

  controller: ($scope, $resource) ->
    SoundPlay =  $resource('/sounds/play',{},{do:{method:'POST'}})
    SoundStop =  $resource('/sounds/stop/:id')
    SoundLevel = $resource('/sounds/level/:id/:power')
    Query = $resource('/sounds/query/:id')

    $scope.started = Query.get {id: $scope.id}, (res) ->
      $scope.song = res.defs

      $scope.playing = res.playing
      $scope.classstyle = 'playStyle' if $scope.playing == true
      # When we are here, fold has been constructed and set to 0.
      $scope.$parent.$$prevSibling.$emit('foldplay') if $scope.playing == true
      $scope.classstyle = 'stopStyle' if $scope.playing == false
      snd = res.level if res.level?
      snd = res.defs.defLevel if not res.level?
      $scope.power = snd


    $scope.playSong = () ->
       SoundPlay.do {id: $scope.id, repeat: $scope.song.loop, name:$scope.song.songFile, power:$scope.power,
       position:$scope.song.position, card:$scope.song.card}, ->
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

@ConfigCtrl = ($scope, $http, $q, $resource)->
    # DMX Stuff.
    Query = $resource('/models/getdefs')
    Update = $resource('/models/setdefs', {}, {set:{method:'POST'}})

    $scope.update = () ->
      Update.set {'dmx_model': $scope.dmxModel, 'dmx_setting':$scope.dmxSetting, 'snd_setting':$scope.sndSetting}, ()->
      alert('Settings updated !')

    Query.get {}, (res) ->
      $scope.dmxModel = res.dmx_model
      $scope.dmxSetting = res.dmx_setting
      $scope.sndSetting = res.snd_setting
      return