# Copyright Xavier Pouyollon 2014
# GPL v3 License

app = angular.module 'myApp', ['ngResource', 'ui.router', 'JSONedit', 'ui.knob', 'ngCookies']

app.config ($stateProvider) ->
  config = {url: "/Config", templateUrl: "/sceniq/config.html", controller: ConfigCtrl}
  faders = {url: "/Fader", templateUrl: "/sceniq/fadercfg.html", controller: FaderCtrl}
  drooms = {url: "/DRooms", templateUrl: "/sceniq/drooms.html", controller:ConfigRoomCtrl}

  # Cameleon
  cameleon =
    url : '/Cameleon'
    templateUrl: "/sceniq/cameleon.html"
    controller: CameleonCtrl

  camdevices =
    url : '/Devices'
    views:
      '':
        templateUrl: 'partials/devs.html'
        controller : DevFixCtrl
      'fixtures@cameleon.devices':
        templateUrl: 'partials/fixtures.html'
        controller: FixturesCtrl
      'machines@cameleon.devices':
        templateUrl: 'partials/devices.html'
        controller : DevicesCtrl

  camscenes =
    'url' : '/cam-associate'
    views:
      '' :
        templateUrl : 'partials/asso.html'
      'machines@cameleon.associate':
        templateUrl: 'partials/machines.html'
        controller : CamMachinesCtrl
      'assettings@cameleon.associate':
        templateUrl : 'partials/associate.html'
        controller : CamAssociateCtrl
      'scenes@cameleon.associate':
        templateUrl : 'partials/scenes.html'
        controller : SceneCtrl

  campictures =
    url: '/cam-pictures'
    views:
      '' :
        templateUrl : 'partials/pict.html'
      'picture@cameleon.pictures':
        templateUrl: 'partials/pictures.html'
        controller : PicturesCtrl
      'pictmngr@cameleon.pictures':
        templateUrl : 'partials/picturesMngr.html'
        controller: PicturesMngrCtrl

  $stateProvider.state('config', config)
  $stateProvider.state('faders', faders)
  $stateProvider.state('drooms', drooms)
  # Declare the cameleon
  $stateProvider.state('cameleon', cameleon)
  $stateProvider.state('cameleon.devices', camdevices)
  $stateProvider.state('cameleon.associate', camscenes)
  $stateProvider.state('cameleon.pictures', campictures)

# Factories
app.factory 'sessionMngr', () ->
  mngr = { 'connected': false}
  mngr.IsConnected = () ->
    return mngr.connected
  mngr.SetConnected = (sessionId) ->
    mngr.connected = true
    mngr.sessionId = sessionId
  return mngr


app.factory 'MenuUtils', ()->
  menus = {}

  menus.UpdateMenu =(list, what)->
      ix = 0
      found = false
      for n in list
        if n.id == what
          found = true
          break
        else
          ix++
      if found
        list[ix]
      else
        null


  return menus

# Let's centralize all the communication to the server.
app.factory 'CameleonServer', ($resource) ->
  datas = {}
  _SettingList = $resource('/cfg/getsettinglist')
  _FaderList = $resource('/dmx/getfaderlist')
  _SlidersList  = $resource('/dmx/faders/:id')
  _SetFader = $resource('/dmx/setfader', {}, {set: {method: 'POST'}})
  _QuerySlider = $resource('/dmx/query/:id/:key')
  _DmxSet = $resource('/dmx/set', {}, {set: {method: 'POST'}})
  _RecordSetting = $resource('/dmx/recordsetting/:fader/:setname')
  _GetSceneList = $resource('/cameleon/getscenelist')
  _CreateScene = $resource('/cameleon/createscene/:scene')
  _RecordScene = $resource('/cameleon/recordscene', {}, {set: {method: 'POST'}})
  _LoadScene = $resource('/cameleon/loadscene/:scene')
  _GetPicturesList = $resource('/cameleon/getpictureslist')
  _CreatePicture = $resource('/cameleon/createpicture/:picture')
  _RecordPicture = $resource('/cameleon/recordpicture', {}, {set: {method: 'POST'}})
  _LoadPicture = $resource('/cameleon/loadpicture/:picture')
  _GetSoundList =  $resource('/cameleon/getsoundlist/:empty')
  _DmxScene = $resource('/cameleon/dmxscene', {}, {set: {method: 'POST'}})
  _GetDevices = $resource('/cameleon/getdevices')
  _GetFixtures = $resource('/cameleon/getfixtures')
  _UpdateDevices = $resource('/cameleon/updatedevices', {}, {set: {method: 'POST'}})
  _UpdateFixtures = $resource('/cameleon/updatefixtures', {}, {set: {method: 'POST'}})

  datas.GetMachinesList = () ->
    return _FaderList.get {}
  datas.GetSettingList = () ->
    return _SettingList.get {}
  datas.GetSliderList = (id) ->
    return _SlidersList.get {id:id}
  datas.SetFaderSetting = (fader, setting) ->
    return _SetFader.set {id: fader, setting:setting}
  datas.QuerySlider = (id, key) ->
    return _QuerySlider.get {id:id, key:key}
  datas.SetSliderCmd = (id, cmds) ->
    return _DmxSet.set {id: id, cmds: cmds}
  datas.RecordFaderSetting = (fader, setname) ->
    return _RecordSetting.get {fader:fader, setname: setname}
  datas.GetSceneList = ()->
    return _GetSceneList.get {}
  datas.CreateScene = (scene) ->
    return _CreateScene.get {scene: scene}
  datas.RecordScene = (scene, machines)->
    return _RecordScene.set {scene: scene, machines: machines}
  datas.LoadScene = (scene)->
    return _LoadScene.get {scene: scene}
  datas.GetPicturesList = ()->
    return _GetPicturesList.get {}
  datas.CreatePicture = (picture) ->
    return _CreatePicture.get {picture: picture}
  datas.RecordPicture = (picture, stuff)->
    return _RecordPicture.set {picture: picture, stuff: stuff}
  datas.LoadPicture = (picture)->
    return _LoadPicture.get {picture: picture}
  datas.GetSoundList = (empty = false)->
    return _GetSoundList.get {empty : empty}
  datas.DmxScene = (scene,opts)->
    return _DmxScene.set {scene:scene, opts:opts}
  datas.GetDevices = ()->
    return _GetDevices.get {}
  datas.GetFixtures = ()->
    return _GetFixtures.get {}
  datas.UpdateDevices = (devices) ->
    return _UpdateDevices.set {devices: devices}
  datas.UpdateFixtures = (fixtures) ->
    return _UpdateFixtures.set {fixtures: fixtures}
  return datas


Array::move = (old_index, new_index) ->
  @splice new_index, 0, @splice(old_index, 1)[0]

# Directive

# Display the various dynamic buttons.
app.directive "widgets", (MenuUtils) ->
  restrict: 'E'
  templateUrl: '/sceniq/templates/widgets.html'
  scope : true

  link: (scope, elemt, attrs) ->
    scope.forward = (index)->
      scope.stuff.move(index, index+1)
    scope.backward = (index)->
      scope.stuff.move(index, index-1) if index > 0
    scope.separator = (index)->
      scope.stuff.splice(index,0,{'msg':'', 'type':'line'})
    scope.remove = (index)->
      scope.stuff.splice(index, 1)

    scope.setStart = (stuff, wrapper)->
      stuff.startSong = wrapper.entry.id

    scope.getStartSound = (stuff, wrapper)->
      return if scope.edit == false
      if 'startSong' of stuff
        wrapper.entry = MenuUtils.UpdateMenu(scope.cameleon.associatesoundslist,stuff.startSong)

    # Init
    scope.$watch attrs.things, (n,o)->
      scope.stuff = n

    if 'edit' of attrs
      scope.$watch attrs.edit, (n,o)->
        scope.edit = n
    else
        scope.edit = false
    return

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

app.directive "dmxSlider", (CameleonServer) ->
  restrict: 'E'
  templateUrl: '/sceniq/templates/dmxslider.html'
  scope: true

  link: (scope, elemt, attrs) ->

    scope.started = () ->
      CameleonServer.QuerySlider(scope.id, scope.key).$promise.then (res) ->
        scope.value = res[scope.key]
        scope.knobOptions = res['knob']

        scope.$on 'update', (sender, evt) ->
          if (evt.id != scope.id) or (evt.key != scope.key)
            return
          scope.value = evt.val
        scope.showMe = true

    scope.send = () ->
      cmd = {}
      cmd[scope.key] = scope.value
      CameleonServer.SetSliderCmd(scope.id, cmd).$promise.then ()->
        scope.$emit('sliderChanged', {'id' : scope.id})

    scope.showMe = true
    scope.id = attrs.id
    scope.key = attrs.key
    scope.def = attrs.def
    scope.name = attrs.name

    scope.started()

# Keep it for now
# TODO: Remove it once dmxScene is available.

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

# This asks the server to display the scene.
app.directive "dmxScene", ->
  restrict: 'E'
  templateUrl: '/sceniq/templates/dmxscene.html'
  scope: {id: '@', 'startsong' : '@'}

  controller: ($scope, CameleonServer) ->

    $scope.dmxstyle = 'dmx'

    $scope.do = () ->
      opts =
        'startsong' : $scope.startsong
        'endsong' : ''

      CameleonServer.DmxScene($scope.id, opts).$promise.then (evt)->
        return

    $scope.$on 'sceneState', (sender, evt) ->
      if (evt.id != $scope.id)
        return
      $scope.active = "running" if evt.state == true
      $scope.active = null if evt.state == false

    return

app.directive "dmxFader", (CameleonServer, $resource, $parse) ->
  restrict: 'E'
  scope : true
  templateUrl: '/sceniq/templates/dmxfader.html'

  link: (scope, elemt, attrs) ->

    Generate = $resource('/dmx/generate/:fader/:setting/:prefix')

    scope.record = (fader, wrapper) ->
      if (wrapper is undefined) or (wrapper == '')
        #RecordSetting.get {fader: fader, setname: ''}
        alert ('You must enter a setting name !')
      else
        CameleonServer.RecordFaderSetting(scope.id, wrapper.name).$promise.then (evt)->
            CameleonServer.GetSettingList().$promise.then (res)->
              scope.settings = res.settings
              scope.currentSetting = wrapper.name
              wrapper.name = ""

    scope.showMe = () ->
      return false if scope.settings == undefined
      return true

    scope.computeCssClass = (last) ->
      if (last == true)
        return null
      else
        return "leftpos"

    scope.$watch 'currentSetting', (n,o)->
      # Call the function
      if (n == o)
        return

      $parse(attrs.settingChanged)(scope, {newSetting : n})
      if n == ''
        return
      CameleonServer.SetFaderSetting(scope.id, n)

    # When the setting changes.
    scope.SetSetting = (fader, setting) ->
      scope.currentSetting = setting

    scope.RefreshDropBox = () ->
      return if scope.settings is undefined
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
    scope.currentSetting = ''

    scope.InitMenu = () ->
      scope.setting.menu = scope.settings[0]

    # As soon as the scope.settings changes, update the drop box menu.
    scope.$watch 'settings', (n,o) ->
        scope.RefreshDropBox()

    # Observe the id
    attrs.$observe 'id', (v) ->
      return if v == ''
      scope.id = v
      CameleonServer.GetSliderList(v).$promise.then (res)->
        scope.sliders = res.res
        scope.showIt = true
      CameleonServer.GetSettingList().$promise.then (res)->
        scope.settings = res.settings

    scope.$on 'setFaderSetting', (sender, evt) ->
      if (evt.id != scope.id)
        return
      if evt.setting != scope.currentSetting
        scope.currentSetting = evt.setting
        scope.RefreshDropBox()

    scope.$on 'sliderChanged', (sender, evt) ->
      return if scope.id != evt.id
      scope.currentSetting = ''
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

@FaderCtrl = ($scope, CameleonServer)->
  # Init of the controller.
  CameleonServer.GetMachinesList().$promise.then (res)->
    $scope.faderlist = res.list

@ConfigRoomCtrl = ($scope, CameleonServer)->
  $scope.cameleon = {}
  CameleonServer.GetPicturesList().$promise.then (res)->
    $scope.cameleon.picturesList = res.list

  $scope.load = ()->
      CameleonServer.LoadPicture($scope.cameleon.currentPicture.id).$promise.then (res)->
        $scope.cameleon.picturesStuff = res.load.list

# This controller defines the fixtures
@FixturesCtrl = ($scope, CameleonServer)->
  $scope.selected = (fixture)->
    list = []
    for k of fixture.v.defs
      list.push({'k': k, 'v': fixture.v.defs[k]})
    $scope.fixtureInfo = list

  $scope.updateFixture = (id, fixinfo)->
    $scope.fixtures[id].defs = {}
    for e in fixinfo
      $scope.fixtures[id].defs[e.k] = e.v
    CameleonServer.UpdateFixtures($scope.fixtures)
    alert ('Updated !')

  $scope.remove = (index, fixinfo)->
    fixinfo.splice(index,1)

  $scope.addKey = (stuff,id)->
    obj = JSON.parse(stuff)
    $scope.fixtures[id].defs[obj.k] = ''
    $scope.fixtures[id].knobs[obj.k] = { 'fgColor' : obj.v}
    CameleonServer.UpdateFixtures($scope.fixtures).$promise.then (evt)->
      $scope.getfixtures()

# This controller creates new devices.
@DevicesCtrl = ($scope, CameleonServer, MenuUtils) ->
  $scope.updateFixture = (machine)->
    machine.v.fixture = $scope.fixtureEntry.id

  $scope.selected = (machine)->
    $scope.fixtureEntry =MenuUtils.UpdateMenu($scope.cameleon.fixtureList, machine.v.fixture)

  $scope.addDevice = ()->
    $scope.devices[$scope.devName] =
      channel : ''
      fixture : ''
    $scope.createDevice = false
    CameleonServer.UpdateDevices($scope.devices).$promise.then (evt)->
      $scope.getdevices()

  $scope.updateDevices = () ->
    CameleonServer.UpdateDevices($scope.devices).$promise.then (evt)->
      alert 'Update done !'

  $scope.fixtureEntry = {}

@DevFixCtrl = ($scope, CameleonServer) ->
  $scope.getfixtures = ()->
    CameleonServer.GetFixtures().$promise.then (res)->
      $scope.fixtures = res.fixtures
      list = []
      for k,v of res.fixtures
        list.push {'id': k, 'v':v}
      $scope.cameleon.fixtureList = list

  $scope.getdevices = ()->
    CameleonServer.GetDevices().$promise.then (res)->
      $scope.devices = res.devices
      list = []
      for k,v of res.devices
        list.push {'id': k, 'v':v}
      $scope.cameleon.machinesList = list

  # Init
  $scope.getdevices()
  $scope.getfixtures()

# This controller adds or removes machines.
@CamMachinesCtrl = ($scope, CameleonServer) ->

  $scope.findMachine = (id) ->
    ix = 0
    for m in $scope.cameleon.machines
      if m.id == id
        return ix
      ix++
    return -1

  # Get the list of machines.
  CameleonServer.GetMachinesList().$promise.then (res)->
    $scope.cameleon.machinesList = res.list
    $scope.cameleon.currentMachine = $scope.cameleon.machinesList[0]

  $scope.addMachine = (currentMachine)->
    index = $scope.findMachine currentMachine.id
    return if index != -1
    currentMachine.setting = ''
    $scope.cameleon.machines.push currentMachine
    return

  $scope.removeMachine = (currentMachine)->
    index = $scope.findMachine currentMachine.id
    return if index == -1
    $scope.cameleon.machines.splice(index,1)
    $scope.cameleon.curMachine = null
    return

# This controller handles the scenes.
# TODO: Rename me as SceneCtrl
@CamAssociateCtrl = ($scope, CameleonServer) ->
  #Init
  $scope.cameleon.curMachine = null

  $scope.selectMachine = (machine) ->
    $scope.cameleon.curMachine = machine
    CameleonServer.SetFaderSetting(machine.id,machine.setting)

  # Here lies all the magic : When a setting is changed, get the new setting
  # and we can add it in the machine associated field.

  $scope.update_setting = (newSetting) ->
    for m in $scope.cameleon.machines
      if m == $scope.cameleon.curMachine
        m.setting = newSetting

# TODO: RenameMe as SceneMngrCtrl
@SceneCtrl = ($scope, CameleonServer, MenuUtils)->

  $scope.showCreate = false

    # As soon as the scope.settings changes, update the drop box menu.
  $scope.$watch 'cameleon.scenesList', (n,o) ->
      $scope.cameleon.currentScene = MenuUtils.UpdateMenu($scope.cameleon.scenesList, $scope.cameleon.currentScene.id)

  $scope.showNew = ()->
    $scope.showCreate = true

  $scope.addScene = (scene)->
    CameleonServer.CreateScene(scene).$promise.then (evt)->
        CameleonServer.GetSceneList().$promise.then (res)->
          $scope.cameleon.currentScene.id = scene
          $scope.cameleon.scenesList = res.list
          $scope.showCreate = false

  $scope.record = () ->
    CameleonServer.RecordScene($scope.cameleon.currentScene.id, $scope.cameleon.machines).$promise.then (evt)->
      alert ('Scene recorded !')

  $scope.load = () ->
    return if $scope.cameleon.currentScene.id == null
    r = window.confirm ('Do you want to load ?')
    if r == true
      $scope.LoadScene()
    else
      alert ('Beware !')

@PicturesCtrl = ($scope, CameleonServer)->
  # Init
  $scope.cameleon.currentScene = $scope.cameleon.scenesList[0]
  $scope.cameleon.currentSound = $scope.cameleon.soundslist[0]

  # When click on dropmenu, load the scene to see the projector.
  $scope.load = () ->
    $scope.LoadScene()

  $scope.findStuff = (id, type) ->
    ix = 0
    for s in $scope.cameleon.picturesStuff
      if (s.id == id) and (s.type == type)
        return ix
      ix++
    return -1

  $scope.addScene = ()->
    entry = {'id' : $scope.cameleon.currentScene.id, 'type':'scene'}
    index = $scope.findStuff(entry.id, entry.type)
    return if index != -1
    $scope.cameleon.picturesStuff.push entry

  $scope.removeScene = ()->
    index = $scope.findStuff($scope.cameleon.currentScene.id, 'scene')
    return if index == -1
    $scope.cameleon.picturesStuff.splice(index,1)

  $scope.addSound = ()->
    entry = {'id' : $scope.cameleon.currentSound.id, 'type':'sound'}
    index = $scope.findStuff(entry.id, entry.type)
    return if index != -1
    $scope.cameleon.picturesStuff.push entry

  $scope.removeSound = ()->
    index = $scope.findStuff($scope.cameleon.currentSound.id, 'sound')
    return if index == -1
    $scope.cameleon.picturesStuff.splice(index,1)

# This controller handles the picture (Tableaux) creations.
@PicturesMngrCtrl = ($scope, CameleonServer, MenuUtils)->

    # As soon as the scope.settings changes, update the drop box menu.
  $scope.$watch 'cameleon.picturesList', (n,o) ->
      return if $scope.cameleon.currentPicture == null
      $scope.cameleon.currentPicture = MenuUtils.UpdateMenu($scope.cameleon.picturesList, $scope.cameleon.currentPicture.id)

  $scope.showNew = ()->
    $scope.showCreate = true

  $scope.addPicture = (picture)->
    CameleonServer.CreatePicture(picture).$promise.then (evt)->
        CameleonServer.GetPicturesList().$promise.then (res)->
          $scope.cameleon.currentPicture.id = picture
          $scope.cameleon.picturesList = res.list
          $scope.showCreate = false

  $scope.record = () ->
    CameleonServer.RecordPicture($scope.cameleon.currentPicture.id, $scope.cameleon.picturesStuff).$promise.then (evt)->
      alert ('Picture recorded !')

  $scope.load = () ->
    return if $scope.cameleon.currentPicture.id == null
    r = window.confirm ('Do you want to load ?')
    if r == true
      $scope.LoadPicture()
    else
      alert ('Beware !')

@CameleonCtrl = ($scope, CameleonServer)->
  # Init
  $scope.cameleon = {}
  # $scope.machines is the list of machines we do use in the current scene
  $scope.cameleon.machines = []
  $scope.cameleon.currentScene = { id : null, name : ''}

  # Scenes
  CameleonServer.GetSceneList().$promise.then (res)->
    $scope.cameleon.scenesList = res.list

  $scope.LoadScene = ()->
      CameleonServer.LoadScene($scope.cameleon.currentScene.id).$promise.then (res)->
        $scope.cameleon.machines = res.load.list
        # Once loaded, take the first machine.
        $scope.cameleon.curMachine = $scope.cameleon.machines[0]

  # Pictures
  $scope.cameleon.picturesStuff = []
  $scope.cameleon.currentPicture = { id: null}

  CameleonServer.GetPicturesList().$promise.then (res)->
    $scope.cameleon.picturesList = res.list

  $scope.LoadPicture = ()->
      CameleonServer.LoadPicture($scope.cameleon.currentPicture.id).$promise.then (res)->
        $scope.cameleon.picturesStuff = res.load.list

  # Sounds
  $scope.cameleon.currentSound = { id : null, name : ''}
  CameleonServer.GetSoundList().$promise.then (res)->
    $scope.cameleon.soundslist = res.list

  $scope.cameleon.currentSound = { id : null, name : ''}
  CameleonServer.GetSoundList(true).$promise.then (res)->
    $scope.cameleon.associatesoundslist = res.list


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
