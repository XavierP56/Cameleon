# Copyright Xavier Pouyollon 2014
# GPL v3 License

app = angular.module 'myApp', ['ngResource', 'ui.router', 'JSONedit', 'ui.knob', 'ngCookies']

app.config ($stateProvider) ->
  room1 = {url: "/Room1", templateUrl: "/profiles/room1.html", controller: RoomCtrl}
  room2 = {url: "/Room2", templateUrl: "/profiles/room2.html", controller: RoomCtrl}
  room3 = {url: "/Room3", templateUrl: "/profiles/room3.html", controller: RoomCtrl}
  room4 = {url: "/Room4", templateUrl: "/profiles/room4.html", controller: RoomCtrl}
  room5 = {url: "/Room5", templateUrl: "/profiles/room5.html", controller: RoomCtrl}
  room6 = {url: "/Room6", templateUrl: "/profiles/room6.html", controller: RoomCtrl}
  room7 = {url: "/Room7", templateUrl: "/profiles/room7.html", controller: RoomCtrl}
  room8 = {url: "/Room8", templateUrl: "/profiles/room8.html", controller: RoomCtrl}
  config = {url: "/Config", templateUrl: "/sceniq/config.html", controller: ConfigCtrl}
  faders = {url: "/Fader", templateUrl: "/sceniq/fadercfg.html", controller: FaderCtrl}
  confdrooms = {url: "/CRoom", templateUrl: "/sceniq/dconf.html", controller:ConfigRoomCtrl}
  drooms = {url: "/DRooms", templateUrl: "/sceniq/drooms.html", controller:ConfigRoomCtrl}

  # Cameleon
  cameleon =
    'url' : '/Cameleon'
    templateUrl: "/sceniq/cameleon.html"
    controller: CameleonCtrl

  cammachines =
    'url': '/machines'
    'templateUrl': 'partials/machines.html'
    controller : CamMachinesCtrl

  camscenes =
    'url' : '/scenes'
    'templateUrl': 'partials/scenes.html'
    controller : CamScenesCtrl

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
  $stateProvider.state('confdrooms', confdrooms)
  $stateProvider.state('drooms', drooms)
  # Declare the cameleon
  $stateProvider.state('cameleon', cameleon)
  $stateProvider.state('cameleon.machines', cammachines)
  $stateProvider.state('cameleon.scenes', camscenes)

# Factories
app.factory 'sessionMngr', () ->
  mngr = { 'connected': false}
  mngr.IsConnected = () ->
    return mngr.connected
  mngr.SetConnected = (sessionId) ->
    mngr.connected = true
    mngr.sessionId = sessionId
  return mngr

app.factory 'configMngr', ($resource) ->
  datas = {}
  Query = $resource('/cfg/getsettinglist')

  datas.LoadSettingsList = () ->
    return Query.get {}, (res) ->
      datas.settingLst = res.settings

  datas.GetSettingList = () ->
    return datas.settingLst

  return datas

# Let's centralize all the communication to the server.
app.factory 'CameleonServer', ($resource) ->
  datas = {}
  Query = $resource('/cfg/getsettinglist')
  FaderList = $resource('/dmx/getfaderlist')

  datas.GetMachinesList = () ->
    return FaderList.get {}

  return datas


# Directive
app.directive "widgets", ->
  restrict: 'E'
  templateUrl: '/sceniq/templates/widgets.html'
  scope : {stuff : '=things'}

  link: (scope, elemt, attrs) ->



app.directive "fold", ->
  restrict: 'E'
  templateUrl: '/sceniq/templates/fold.html'
  scope: {foldName: '@'}
  transclude: true

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
  restrict: 'E'
  templateUrl: '/sceniq/templates/dmxslider.html'
  scope: true

  link: (scope, elemt, attrs) ->
    Query = $resource('/dmx/query/:id/:key')
    DmxSet = $resource('/dmx/set', {}, {set: {method: 'POST'}})

    scope.started = () ->
      Query.get {id: scope.id, key: scope.key}, (res) ->
        scope.value = res[scope.key]
        scope.send()
        scope.knobOptions = res['knob']

        scope.$on 'update', (sender, evt) ->
          if (evt.id != scope.id) or (evt.key != scope.key)
            return
          scope.value = evt.val
        scope.showMe = true

    scope.send = () ->
      cmd = {}
      cmd[scope.key] = scope.value
      DmxSet.set {id: scope.id, cmds: cmd}, ->
        scope.$emit('sliderChanged', {'id' : scope.id})
        return

    scope.showMe = true
    scope.id = attrs.id
    scope.key = attrs.key
    scope.def = attrs.def
    scope.name = attrs.name

    scope.started()

app.directive "dmxLight", ->
  restrict: 'E'
  templateUrl: '/sceniq/templates/dmxlight.html'
  scope: {id: '@'}

  controller: ($scope, $resource) ->
    LightQuery = $resource('/dmx/light/:id')
    DmxSetLight = $resource('/dmx/setLight/:light')

    LightQuery.get {id: $scope.id}, (res)->
      $scope.light = res.light
      if $scope.light.hasOwnProperty('transition')
        $scope.dmxstyle = 'dmx' if $scope.light.transition == "False"
        $scope.dmxstyle = 'transit' if $scope.light.transition == "True"
      else
        $scope.dmxstyle = 'list'

      if res.active == true
        $scope.active = "running"

    $scope.do = () ->
      DmxSetLight.get {light: $scope.id}, (res)->
        return

    $scope.$on 'activeLight', (sender, evt) ->
      if (evt.group != $scope.light.group)
        return
      if (evt.light != $scope.id)
        $scope.active = null
      else
        $scope.active = "running"
    return

app.directive "dmxFader", ($resource) ->
  restrict: 'E'
  scope : true
  templateUrl: '/sceniq/templates/dmxfader.html'

  link: (scope, elemt, attrs) ->
    Sliders = $resource('/dmx/faders/:id')
    SetFader = $resource('/dmx/setfader/:fader/:setting')
    Generate = $resource('/dmx/generate/:fader/:setting/:prefix')

    scope.showMe = () ->
      return false if scope.settings == undefined
      return true

    scope.computeCssClass = (last) ->
      if (last == true)
        return null
      else
        return "leftpos"

    scope.SetSetting = (fader, setting) ->
      if setting == '-------'
        return
      SetFader.get {fader: fader, setting: setting}

    scope.RefreshDropBox = () ->
      ix = 0
      for n in scope.settings
        if n.name == scope.currentSetting
          break
        else
          ix++
      scope.setting.menu = scope.settings[ix]

    # Init
    scope.setting = {}
    scope.setting.menu = {'name' :'me'}

    scope.InitMenu = () ->
      scope.setting.menu = scope.settings[0]

    scope.$watch attrs.settings, (n,o) ->
      if (n != undefined)
        scope.settings = n
        scope.setting.menu = scope.settings[0]

    attrs.$observe 'id', (v) ->
      scope.id = v
      scope.currentSetting = '-------'
      Sliders.get {id: scope.id}, (res)->
        scope.sliders = res.res
        scope.showIt = true

    scope.$on 'setFaderSetting', (sender, evt) ->
      if (evt.id != scope.id)
        return
      scope.currentSetting = evt.setting
      scope.RefreshDropBox()

    scope.$on 'updateDropBox', (sender, evt) ->
      scope.RefreshDropBox()
      scope.SetSetting(scope.id, scope.currentSetting)

    scope.$on 'refreshDropBox', (sender, evt) ->
      scope.RefreshDropBox()

    scope.$on 'generateAll', (sender, pref) ->
      if scope.currentSetting == '-------'
        return
      Generate.get {fader: scope.id, setting: scope.currentSetting, prefix:pref}

    scope.$on 'sliderChanged', (sender, evt) ->
      return if scope.id != evt.id
      scope.currentSetting = '-------'
      scope.RefreshDropBox()

    # Directive init
    scope.showIt = false


app.directive "soundButton", ($resource)  ->
  restrict: 'E'
  templateUrl: '/sceniq/templates/soundbutton.html'
  scope: true

  link: (scope, elemt, attrs) ->
    # Default Knob settings.
    scope.power = 100
    SoundPlay = $resource('/sounds/play', {}, {do: {method: 'POST'}})
    SoundStop = $resource('/sounds/stop/:id')
    SoundLevel = $resource('/sounds/level/:id/:power')
    Query = $resource('/sounds/query/:id')

    scope.showMe = false

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

        scope.$on 'volumeUpt', (sender, evt) ->
          if evt.id != scope.id
            return
          scope.power = evt.power
        # And show me
        scope.showMe = true

    scope.playSong = () ->
      cmd =
        id: scope.id
        repeat: scope.song.loop
        name: scope.song.songFile
        power: scope.power
        position: scope.song.position
        card: scope.song.card

      SoundPlay.do cmd, ->
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
  Query = $resource('/models/getdefs', {}, {set: {method: 'POST'}})
  Update = $resource('/models/setdefs', {}, {set: {method: 'POST'}})
  Save = $resource('/models/save')

  $scope.update = () ->
    cmd =
      'dmx_model': $scope.dmxModel
      'dmx_setting': $scope.dmxSetting
      'snd_setting': $scope.sndSetting
      'dmx_light': $scope.dmxLight
      'dmx_group': $scope.dmxGroup
      'dmx_fixtures' : $scope.dmxFixtures

    Update.set cmd, ()->
    alert('Settings updated !')

  $scope.save = () ->
    cmd =
      'dmx_model': $scope.dmxModel
      'dmx_setting': $scope.dmxSetting
      'snd_setting': $scope.sndSetting
      'dmx_light': $scope.dmxLight
      'dmx_group': $scope.dmxGroup
      'dmx_fixtures' : $scope.dmxFixtures

    $scope.setDone = Update.set cmd, ()->
      return
    $scope.setDone.$promise.then () ->
      Save.get {}, ->
        alert('Settings saved !')

  Query.set {}, (res) ->
    $scope.dmxModel = res.dmx_model
    $scope.dmxGroup = res.dmx_group
    $scope.dmxSetting = res.dmx_setting
    $scope.dmxLight = res.dmx_light
    $scope.sndSetting = res.snd_setting
    $scope.dmxFixtures = res.dmx_fixtures
    return

  $scope.$on '$stateChangeStart', (event) ->
    #event.preventDefault()

app.filter 'faderFilter', ->
  (input, low, high) ->
    if ((low != undefined) and (high != undefined))
      return input[low..high]
    else
      return input

@FaderCtrl = ($scope, $http, $q, $resource, configMngr)->
  # Nothing. The broadcast is done my the MainCtrl.
  FaderList = $resource('/dmx/getfaderlist')
  RecordSetting = $resource('/dmx/recordsetting/:fader/:setname')

  $scope.record = (fader, wrapper) ->
    if (wrapper is undefined) or (wrapper == '')
      RecordSetting.get {fader: fader, setname: ''}
    else
      RecordSetting.get {fader: fader, setname: wrapper.name}
      wrapper.name = ""

  $scope.record_done = (res) ->
    set_promise = configMngr.LoadSettingsList()
    set_promise.$promise.then (setv) ->
      $scope.settingList = setv.settings
      evt = { 'id': res.fader, 'setting': res.name}
      $scope.$broadcast('setFaderSetting', evt)
      alert (res.msg)
      #$timeout($scope.updateall)
      $scope.updateall()

  $scope.updateall = () ->
    $scope.$broadcast('updateDropBox')

  $scope.generateall = (prefix) ->
    if (prefix is undefined or prefix == '')
      alert ('Prefix must be specified !')
      return
    $scope.$broadcast('generateAll', prefix)
    alert('Light button will be soon generated !')

  # Init of the controller.
  FaderList.get {}, (res)->
    $scope.faderlist = res.list
    set_promise = configMngr.LoadSettingsList()
    set_promise.$promise.then (res) ->
      $scope.settingList = res.settings

  # When a new entry is created, please update.
  $scope.$on 'recordDone', (sender, evt)->
    $scope.record_done (evt)
  return

@ConfigRoomCtrl = ($scope, $http, $q, $resource)->
  $scope.scenes = {}

  Save = $resource('/models/saveDrooms', {}, {set: {method: 'POST'}})
  Load = $resource('/models/loadDrooms')

  $scope.current = ''
  $scope.setting = {}
  $scope.InitMenu = () ->
    $scope.list = []
    keys = Object.keys($scope.scenes).sort()
    for scene in keys
      $scope.list.push({'name' : scene})

    ix = 0
    for n in $scope.list
      if n.name == $scope.current
        break
      else
        ix++
    $scope.setting.scene = $scope.list[ix]

  $scope.update = (name) ->
    $scope.stuff = angular.copy($scope.scenes[name])

  $scope.refresh = (name) ->
    $scope.InitMenu()
    $scope.update(name)

  $scope.SetScene = (scene) ->
    $scope.current = scene.name
    $scope.update($scope.current)

  $scope.save = () ->
    cmd = 'drooms' : $scope.scenes

    $scope.setDone = Save.set cmd, ()->
      return
    $scope.setDone.$promise.then () ->
        alert('Dynamic Rooms saved !')

  $scope.reload = () ->
    Load.get (res) ->
      $scope.scenes = res.drooms
      $scope.refresh($scope.current)

  # Init
  Load.get (res) ->
    $scope.scenes = res.drooms
    $scope.InitMenu()

@CamMachinesCtrl = ($scope, CameleonServer) ->
  # Get the list of machines.
  CameleonServer.GetMachinesList().$promise.then (res)->
    $scope.machinesList = res.list
    $scope.currentMachine = $scope.machinesList[0]

  $scope.addMachine = (currentMachine)->
    index = $scope.machines.indexOf currentMachine
    return if index != -1
    $scope.machines.push currentMachine
    return

  $scope.removeMachine = (currentMachine)->
    index = $scope.machines.indexOf currentMachine
    return if index == -1
    $scope.machines.splice(index,1)
    return

@CamScenesCtrl = ($scope, CameleonServer) ->
  #Init
  $scope.curMachine = {}
  $scope.curSetting = {}

  $scope.selectMachine = (machine) ->
    $scope.curMachine = machine

@CameleonCtrl = ($scope, $http, $q, $resource)->
  # Init

  # $scope.machines is the list of machines we do use.
  $scope.machines = []


@MainCtrl = ($scope, $http, $q, $resource, sessionMngr)->
  SndPanic = $resource('/sounds/panic')
  DmxPanic = $resource('/dmx/panic')
  Query = $resource('/models/scenes')
  CreateSession = $resource('/scenic/newsession')
  ReloadProfile = $resource('/cfg/reloadprofiles')

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

  $scope.dmxPanic = () ->
    DmxPanic.get {}, () ->

  SndCancel = $q.defer()
  DmxCancel = $q.defer()

  sndpromise = SndCancel.promise
  sndpromise.then () ->

  dmxpromise = DmxCancel.promise
  dmxpromise.then () ->

  $scope.reloadProfile = () ->
    ReloadProfile.get {}, () ->
      alert ('Profiles loaded !')

  # POST request to send cookies (sessionId)
  Events = $resource('/sounds/events', {}, {'get': {method: 'POST', timeout: sndpromise}})
  DmxEvents = $resource('/dmx/events', {}, {'get': {method: 'POST', timeout: dmxpromise}})

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
