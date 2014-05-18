# Copyright Xavier Pouyollon 2014
# GPL v3 License

app = angular.module 'myApp', ['ngResource','ui.router','JSONedit','ui.knob','ngCookies']

app.config ($stateProvider) ->
  room1 = {url: "/Room1", templateUrl: "/profiles/room1.html",  controller: RoomCtrl}
  room2 = {url: "/Room2", templateUrl: "/profiles/room2.html",  controller: RoomCtrl}
  room3 = {url: "/Room3", templateUrl: "/profiles/room3.html",  controller: RoomCtrl}
  room4 = {url: "/Room4", templateUrl: "/profiles/room4.html",  controller: RoomCtrl}
  room5 = {url: "/Room5", templateUrl: "/profiles/room5.html",  controller: RoomCtrl}
  room6 = {url: "/Room6", templateUrl: "/profiles/room6.html",  controller: RoomCtrl}
  room7 = {url: "/Room7", templateUrl: "/profiles/room7.html",  controller: RoomCtrl}
  room8 = {url: "/Room8", templateUrl: "/profiles/room8.html",  controller: RoomCtrl}
  config = {url: "/Config", templateUrl: "/sceniq/config.html", controller: ConfigCtrl}
  faders = {url: "/Fader", templateUrl: "/sceniq/fadercfg.html",controller: FaderCtrl}
  $stateProvider.state('room1', room1)
  $stateProvider.state('room2', room2)
  $stateProvider.state('room3', room3)
  $stateProvider.state('room4', room4)
  $stateProvider.state('room5', room5)
  $stateProvider.state('room6', room6)
  $stateProvider.state('room7', room7)
  $stateProvider.state('room8', room8)
  $stateProvider.state('config', config)
  $stateProvider.state('faders', faders)

# Factories
app.factory 'sessionMngr', () ->
  mngr = { 'connected' : false}
  mngr.IsConnected = () ->
    return mngr.connected
  mngr.SetConnected = (sessionId) ->
    mngr.connected = true
    mngr.sessionId = sessionId
  return mngr

app.factory 'configMngr', ($resource) ->
  datas = {}
  Query = $resource('/cfg/getsettinglist')

  datas.GetSettingsList = () ->
    return Query.get {}

  return datas

# Directive
app.directive "fold", ->
  restrict : 'E'
  templateUrl : '/sceniq/templates/fold.html'
  scope : {foldName : '@'}
  transclude : true

  compile: (element, attr, linker) ->
    pre: (scope, element, attr) ->
      linker scope, (clone) -> #bind the scope your self
        element.children().eq(1).append clone # add to DOM
        return

  controller: ($scope) ->
      $scope.nb = 0

      $scope.$on 'foldplay', (sender, evt) ->
        $scope.nb = $scope.nb + 1

      $scope.$on 'foldstop', (sender, evt) ->
        $scope.nb = $scope.nb - 1

app.directive "dmxSlider", ($resource) ->
  restrict : 'E'
  templateUrl : '/sceniq/templates/dmxslider.html'
  scope : true

  link: (scope, elemt, attrs) ->
    Query = $resource('/dmx/query/:id/:key')
    DmxSet = $resource('/dmx/set', {}, {set:{method:'POST'}})

    scope.started = () ->
      Query.get {id: scope.id, key: scope.key}, (res) ->
        scope.value = res[scope.key]
        scope.send()
        scope.knobOptions = res['knob']

        scope.$on 'update', (sender, evt) ->
          if (evt.id != scope.id) or (evt.key != scope.key)
            return
          scope.value = evt.val

    scope.send = () ->
      cmd = {}
      cmd[scope.key] = scope.value
      DmxSet.set {id:scope.id, cmds: cmd}, ->
        return

    scope.id = attrs.id
    scope.key = attrs.key
    scope.def = attrs.def
    scope.name = attrs.name

    scope.started()

app.directive "dmxLight", ->
  restrict : 'E'
  templateUrl : '/sceniq/templates/dmxlight.html'
  scope : {id:'@'}
  transclude : true

  controller: ($scope, $resource) ->
    LightQuery = $resource('/dmx/light/:id')
    DmxSetLight =  $resource('/dmx/setLight/:light')

    LightQuery.get {id:$scope.id}, (res)->
      $scope.light = res.light
      if $scope.light.hasOwnProperty('transition')
        $scope.dmxstyle='dmx' if $scope.light.transition == "False"
        $scope.dmxstyle='transit' if $scope.light.transition == "True"
      else
        $scope.dmxstyle='list'

      if res.active == true
        $scope.active = "running"

    $scope.do= () ->
      DmxSetLight.get {light:$scope.id}, (res)->
        return

    $scope.$on 'activeLight', (sender, evt) ->
      if (evt.group != $scope.light.group)
        return
      if (evt.light != $scope.id)
          $scope.active = null
      else
          $scope.active = "running"
    return

app.directive "dmxFader", ->
  restrict : 'E'
  scope : { id : '@'}
  templateUrl : '/sceniq/templates/dmxfader.html'

  controller: ($scope, $resource) ->
    Sliders = $resource('/dmx/faders/:id')

    Sliders.get {id:$scope.id}, (res)->
      $scope.sliders = res.res

    $scope.computeCssClass = (last) ->
      if (last == true)
        return null
      else
        return "leftpos"


app.directive "soundButton", ($resource)  ->
  restrict : 'E'
  templateUrl : '/sceniq/templates/soundbutton.html'
  scope : true

  link: (scope, elemt, attrs) ->
    # Default Knob settings.

    scope.power = 100
    SoundPlay =  $resource('/sounds/play',{},{do:{method:'POST'}})
    SoundStop =  $resource('/sounds/stop/:id')
    SoundLevel = $resource('/sounds/level/:id/:power')
    Query = $resource('/sounds/query/:id')

    scope.started = () ->
      Query.get {id: scope.id}, (res) ->
        scope.song = res.defs

        scope.playing = res.playing
        scope.classstyle = 'playStyle' if scope.playing == true
        # When we are here, fold has been constructed and set to 0.
        scope.$emit('foldplay') if scope.playing == true
        scope.classstyle = 'stopStyle' if scope.playing == false
        snd = res.level if res.level?
        snd = res.defs.defLevel if not res.level?
        scope.power = snd
        scope.knobOptions = res.knob

        # And handle events.
        scope.$on 'play', (sender, evt) ->
          if evt.id != scope.id
            return
          scope.playing = true
          scope.classstyle = 'playStyle'
          scope.$emit('foldplay')

        scope.$on 'stop', (sender, evt) ->
          if evt.id != scope.id
            return
          scope.playing = false
          scope.classstyle = 'stopStyle'
          scope.$emit('foldstop')


    scope.playSong = () ->
       SoundPlay.do {id: scope.id, repeat: scope.song.loop, name:scope.song.songFile, power:scope.power,
       position:scope.song.position, card:scope.song.card}, ->
         return

    scope.stopSong = () ->
      SoundStop.get {id: scope.id}, ->
         return

    scope.doit = () ->
      # Send request to server
      scope.playSong() if scope.playing == false
      scope.stopSong() if scope.playing == true

    scope.level = () ->
      SoundLevel.get {id: scope.id, power: scope.power}, ->
        return

    scope.mute = () ->
      if scope.power > 0
        scope.muted = scope.power
        scope.power = 0
      else
        scope.power = scope.muted
        scope.muted = 0
      scope.level()
      return

    scope.id = attrs.id
    scope.started()


@RoomCtrl = ($scope, $http, $q, $resource)->
  # Nothing. The broadcast is done my the MainCtrl.
  return


@ConfigCtrl = ($scope, $http, $q, $resource)->
    # DMX Stuff.
    Query = $resource('/models/getdefs')
    Update = $resource('/models/setdefs', {}, {set:{method:'POST'}})
    Save = $resource('/models/save')

    $scope.update = () ->
      Update.set {'dmx_model': $scope.dmxModel, 'dmx_setting':$scope.dmxSetting,'snd_setting':$scope.sndSetting, "dmx_light": $scope.dmxLight}, ()->
      alert('Settings updated !')

    $scope.save = () ->
      $scope.setDone = Update.set {'dmx_model': $scope.dmxModel, 'dmx_setting':$scope.dmxSetting,'snd_setting':$scope.sndSetting, "dmx_light": $scope.dmxLight}, ()->
        return
      $scope.setDone.$promise.then () ->
        Save.get {}, ->
          alert('Settings saved !')

    Query.get {}, (res) ->
      $scope.dmxModel = res.dmx_model
      $scope.dmxGroup = res.dmx_group
      $scope.dmxSetting = res.dmx_setting
      $scope.dmxLight = res.dmx_light
      $scope.sndSetting = res.snd_setting
      return

    $scope.$on '$stateChangeStart', (event) ->
     #event.preventDefault()

app.filter 'faderFilter', ->
  (input,low,high) ->
    if ((low != undefined) and (high != undefined))
      return input[low..high]
    else
      return input

FaderCtrl = ($scope, $http, $q, $resource,configMngr)->
  # Nothing. The broadcast is done my the MainCtrl.
  FaderList = $resource('/dmx/getfaderlist')
  SetFader = $resource('/dmx/setfader/:fader/:setting')
  RecordSetting = $resource('/dmx/recordsetting/:fader')

  $scope.settingList = []



  $scope.SetSetting = (fader, setting) ->
    SetFader.get {fader: fader, setting: setting.menu.name}

  $scope.record = (fader, setting) ->
    RecordSetting.get {fader: fader}, (res)->
      set_promise = configMngr.GetSettingsList()
      set_promise.$promise.then (setv) ->
        $scope.settingList = setv.settings
        ix = 0
        for n in $scope.settingList
          if n.name == res.name
            break
          else
            ix++
        setting.menu = $scope.settingList[ix]
        alert (res.msg)

  # Init of the controller.
  FaderList.get {}, (res)->
    $scope.faderlist = res.list
    set_promise = configMngr.GetSettingsList()
    set_promise.$promise.then (res) ->
      $scope.settingList = res.settings

  return

@MainCtrl = ($scope, $http, $q, $resource,sessionMngr)->
  SndPanic = $resource('/sounds/panic')
  Query = $resource('/models/scenes')
  CreateSession = $resource('/scenic/newsession')

  Query.get {}, (res)->
    $scope.entries = res.scenes

  # See if we need to create a session
  if not sessionMngr.IsConnected()
    CreateSession.get {}, (res) ->
      sessionMngr.SetConnected(res.id)
      # Put it into the http header.
      $http.defaults.headers.post['SessionId'] = res.id

  # Panic button
  $scope.soundPanic = () ->
    SndPanic.get {}, () ->

  SndCancel = $q.defer()
  DmxCancel = $q.defer()

  sndpromise = SndCancel.promise
  sndpromise.then () ->

  dmxpromise = DmxCancel.promise
  dmxpromise.then () ->

  # POST request to send cookies (sessionId)
  Events = $resource('/sounds/events',{},{'get': {method: 'POST', timeout: sndpromise}})
  DmxEvents = $resource('/dmx/events',{},{'get': {method: 'POST', timeout: dmxpromise}})

  $scope.getSoundEvent = () ->
    $scope.promiseGetSnd = Events.get {}
    # Wait for sound event, analyze it and broadcast it.
    $scope.promiseGetSnd.$promise.then (evt)->
        $scope.$broadcast(evt.evt, evt)
        $scope.getSoundEvent()

  # Wait DMX events,  analyze it and broadcast it.
  $scope.getDmxEvent = () ->
    $scope.promiseGetDmx = DmxEvents.get {}
    # Wait DMX events,  analyze it and broadcast it.
    $scope.promiseGetDmx.$promise.then (evt)->
        $scope.$broadcast(evt.evt, evt)
        $scope.getDmxEvent()

  # Trigger them
  $scope.getSoundEvent()
  $scope.getDmxEvent()

  # $scope.$on '$stateChangeStart', (event) ->
  #  SndCancel.resolve()
  #  DmxCancel.resolve()
