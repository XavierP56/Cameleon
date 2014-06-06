# Copyright Xavier Pouyollon 2014
# GPL v3 License

app = angular.module 'myApp', ['ui.bootstrap', 'ngResource', 'ui.router', 'JSONedit', 'ui.knob', 'angularFileUpload' ]

app.config ($stateProvider) ->
  config = {url: "/Config", templateUrl: "/sceniq/config.html", controller: ConfigCtrl}
  faders = {url: "/Fader", templateUrl: "/sceniq/fadercfg.html", controller: FaderCtrl}
  drooms = {url: "/DRooms", templateUrl: "/sceniq/drooms.html", controller:ConfigRoomCtrl}

  # Cameleon
  cameleon =
    url : '/Cameleon'
    templateUrl: "/sceniq/cameleon.html"
    controller: CameleonCtrl

  camsettings =
    url : '/Settings'
    templateUrl: 'partials/devs.html'
    controller: DevFixCtrl

  camfixtures =
    url : '/Fixtures'
    templateUrl: 'partials/fixtures.html'
    controller: FixturesCtrl

  camdevices =
    url : '/Devices'
    templateUrl: 'partials/devices.html'
    controller : DevicesCtrl

  camsounds =
    url : '/Sounds'
    templateUrl: 'partials/sounds.html'
    controller : SoundsCtrl

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

  $stateProvider.state('drooms', drooms)
  # Declare the cameleon
  $stateProvider.state('cameleon', cameleon)
  $stateProvider.state('cameleon.settings', camsettings)
  $stateProvider.state('cameleon.settings.fixtures', camfixtures)
  $stateProvider.state('cameleon.settings.devices', camdevices)
  $stateProvider.state('cameleon.settings.sounds', camsounds)
  $stateProvider.state('cameleon.faders', faders)
  $stateProvider.state('cameleon.config', config)
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
        {}

  return menus

app.factory 'AlertUtils', ($modal)->
  alert = {}

  alert.showMsg = (msg)->
    return $modal.open(
       templateUrl: 'partials/Confirm.html'
       controller : ConfirmCtrl,
       resolve :
          bodyText : () -> msg
          onlyOK : ()->true
     )

  alert.showConfirm = (msg,ok,notok)->
    modalInstance = $modal.open(
       templateUrl: 'partials/Confirm.html'
       controller : ConfirmCtrl,
       resolve :
          bodyText : () -> msg
          onlyOK : ()->false
    )
    modalInstance.result.then (name)->
      ok()
    , (name)->
      notok()
    return

  return alert

app.factory 'CameleonUtils', () ->
  utils = {}

  utils.sortedKeys = (o)->
    r = []
    for k of o
      r.push(k)
    return r.sort()

  return utils
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
  _GetSceneState = $resource('/cameleon/getscenestate/:scene')
  _GetDevices = $resource('/cameleon/getdevices')
  _GetFixtures = $resource('/cameleon/getfixtures')
  _UpdateDevices = $resource('/cameleon/updatedevices', {}, {set: {method: 'POST'}})
  _UpdateFixtures = $resource('/cameleon/updatefixtures', {}, {set: {method: 'POST'}})
  _GetSounds = $resource('/cameleon/getsounds')
  _UpdateSounds = $resource('/cameleon/updatesounds', {}, {set: {method: 'POST'}})
  _GetDebugDatas = $resource('/models/getdefs')
  _UpdateDebugDatas = $resource('/models/setdefs', {}, {set: {method: 'POST'}})
  _SaveDebugDatas = $resource('/models/save')
  _TurnOff = $resource('/cameleon/turnoff')
  _Reboot =  $resource('/cameleon/reboot')

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
  datas.GetSounds = ()->
    return _GetSounds.get {}
  datas.UpdateSounds = (sounds) ->
    return _UpdateSounds.set {sounds: sounds}
  datas.GetDebugDatas = ()->
    return _GetDebugDatas.get {}
  datas.UpdateDebugDatas = (cmd)->
    return _UpdateDebugDatas.set cmd
  datas.SaveDebugDatas = ()->
    return _SaveDebugDatas.get {}
  datas.GetSceneState = (scene)->
    return _GetSceneState.get {scene : scene}
  datas.TurnOff = ()->
    return _TurnOff.get {}
  datas.Reboot = ()->
    return _Reboot.get {}
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

# This asks the server to display the scene.
app.directive "dmxScene", ->
  restrict: 'E'
  templateUrl: '/sceniq/templates/dmxscene.html'
  scope: {id: '@', 'startsong' : '@'}

  controller: ($scope, CameleonServer) ->

    $scope.dmxstyle = 'dmx'
    CameleonServer.GetSceneState($scope.id).$promise.then (evt)->
      $scope.active = "running" if evt.state == true
      $scope.active = null if evt.state == false

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

app.directive "dmxFader", (CameleonServer, $resource, $parse,$modal,AlertUtils) ->
  restrict: 'E'
  scope : true
  templateUrl: '/sceniq/templates/dmxfader.html'

  link: (scope, elemt, attrs) ->

    Generate = $resource('/dmx/generate/:fader/:setting/:prefix')

    scope.createSetting = (fader, wrapper)->
     modalInstance = $modal.open(
       templateUrl: 'partials/ModalName.html'
       controller : NameCtrl,
       resolve :
          headerName : () -> 'Pleaser enter setting name'
     )
     modalInstance.result.then (name)->
       scope.record(fader, name)
     , (name)->

    scope.record = (fader, name) ->
      if (name is undefined) or (name == '')
        AlertUtils.showMsg ('You must enter a setting name !')
      else
        CameleonServer.RecordFaderSetting(scope.id, name).$promise.then (evt)->
            CameleonServer.GetSettingList().$promise.then (res)->
              scope.settings = res.settings
              scope.currentSetting = name

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


@ConfigCtrl = ($scope, CameleonServer, $resource,AlertUtils)->
  # DMX Stuff.
  $scope.update = () ->
    cmd =
      'snd_setting': $scope.sndSetting
      'dmx_fixtures' : $scope.dmxFixtures
      'dmx_model': $scope.dmxModel
      'dmx_setting': $scope.dmxSetting
      'camscenes': $scope.camscenes
      'campictures': $scope.campictures

    CameleonServer.UpdateDebugDatas(cmd).$promise.then (evt)->
      AlertUtils.showMsg('Settings updated !')

  $scope.save = () ->
    cmd =
      'snd_setting': $scope.sndSetting
      'dmx_fixtures' : $scope.dmxFixtures
      'dmx_model': $scope.dmxModel
      'dmx_setting': $scope.dmxSetting
      'camscenes': $scope.camscenes
      'campictures': $scope.campictures

    CameleonServer.UpdateDebugDatas(cmd).$promise.then ()->
      CameleonServer.SaveDebugDatas().$promise.then ()->
        AlertUtils.showMsg('Settings saved !')

  CameleonServer.GetDebugDatas().$promise.then (res)->
    $scope.sndSetting = res.snd_setting
    $scope.dmxFixtures = res.dmx_fixtures
    $scope.dmxModel = res.dmx_model
    $scope.dmxSetting = res.dmx_setting
    $scope.camscenes = res.camscenes
    $scope.campictures = res.campictures
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

# Defines the confirm controller.
@ConfirmCtrl = ($scope, $modal, $modalInstance, bodyText, onlyOK)->
  $scope.bodyText = {}
  $scope.bodyText.text = bodyText
  $scope.bodyText.onlyOK = onlyOK
  $scope.ok = () ->
    $modalInstance.close('');
  $scope.cancel =  () ->
    $modalInstance.dismiss('cancel')

# Defines the name controller.
@NameCtrl = ($scope, $modal, $modalInstance,headerName)->
  $scope.headerName = headerName
  $scope.data = {}
  $scope.data.name = ''
  $scope.ok = () ->
    $modalInstance.close($scope.data.name);
  $scope.cancel =  () ->
    $modalInstance.dismiss('cancel')

# This controller defines the fixtures
@FixturesCtrl = ($scope, CameleonServer, MenuUtils,$modal,AlertUtils,CameleonUtils)->
  $scope.selected = (fixture)->
    list = []
    for k in CameleonUtils.sortedKeys(fixture.v.defs)
      list.push({'k': k, 'v': fixture.v.defs[k]})
    $scope.fixtureInfo = list

  $scope.updateFixture = (id, fixinfo)->
    $scope.fixtures[id].defs = {}
    for e in fixinfo
      $scope.fixtures[id].defs[e.k] = e.v
    CameleonServer.UpdateFixtures($scope.fixtures).$promise.then (evt)->
      AlertUtils.showMsg ('Updated !')

  $scope.remove = (index, fixinfo)->
    fixinfo.splice(index,1)

  $scope.createFixture = ()->
     modalInstance = $modal.open(
       templateUrl: 'partials/ModalName.html'
       controller : NameCtrl,
       resolve :
          headerName : ()-> 'Please enter fixture name'
     )
     modalInstance.result.then (name)->
       $scope.addFixture(name)


  $scope.addFixture = (name)->
    $scope.fixtures[name] = {'defs' : {}, 'knobs': {}}
    CameleonServer.UpdateFixtures($scope.fixtures).$promise.then (evt)->
      $scope.getfixtures().promise.then ()->
        $scope.fixtureEntry = MenuUtils.UpdateMenu($scope.cameleon.fixtureList,name)
        $scope.selected($scope.fixtureEntry)

  $scope.addKey = (stuff,id)->
    obj = JSON.parse(stuff)
    $scope.fixtures[id].defs[obj.k] = ''
    if obj.v != ''
      $scope.fixtures[id].knobs[obj.k] = { 'fgColor' : obj.v}
    CameleonServer.UpdateFixtures($scope.fixtures).$promise.then (evt)->
      $scope.getfixtures().promise.then ()->
        $scope.selected($scope.fixtureEntry)
        $scope.fixtureEntry = MenuUtils.UpdateMenu($scope.cameleon.fixtureList,id)


  $scope.addCustom = (stuff,id)->
    $scope.fixtures[id].defs[stuff] = ''
    CameleonServer.UpdateFixtures($scope.fixtures).$promise.then (evt)->
      $scope.getfixtures().promise.then ()->
        $scope.selected($scope.fixtureEntry)
        $scope.fixtureEntry = MenuUtils.UpdateMenu($scope.cameleon.fixtureList,id)


# This controller creates new devices.
@DevicesCtrl = ($scope, CameleonServer, MenuUtils,$modal,AlertUtils) ->
  $scope.updateFixture = (machine)->
    machine.v.fixture = $scope.fixtureEntry.id

  $scope.selected = (machine)->
    $scope.fixtureEntry =MenuUtils.UpdateMenu($scope.cameleon.fixtureList, machine.v.fixture)

  $scope.createDevice = ()->
     modalInstance = $modal.open(
       templateUrl: 'partials/ModalName.html'
       controller : NameCtrl,
       resolve :
          headerName : ()-> 'Please enter device name'
     )
     modalInstance.result.then (name)->
       $scope.addDevice(name)

  $scope.addDevice = (name)->
    $scope.devices[name] =
      channel : ''
      fixture : ''
    CameleonServer.UpdateDevices($scope.devices).$promise.then (evt)->
      $scope.getdevices().promise.then ()->
        $scope.cameleon.currentMachine = MenuUtils.UpdateMenu($scope.cameleon.machinesList, name)
        $scope.selected($scope.cameleon.currentMachine)

  $scope.updateDevices = () ->
    CameleonServer.UpdateDevices($scope.devices).$promise.then (evt)->
      AlertUtils.showMsg 'Update done !'

  $scope.checkStuff = ()->
    if $scope.cameleon.currentMachine == undefined
      return true
    if $scope.cameleon.currentMachine.v.channel == ''
      return true
    if $scope.fixtureEntry == null
      return true
    return false

  $scope.fixtureEntry = {}

@DevFixCtrl = ($scope, CameleonServer,CameleonUtils,$q) ->
  $scope.getfixtures = ()->
    promise = $q.defer()
    CameleonServer.GetFixtures().$promise.then (res)->
      $scope.fixtures = res.fixtures
      list = []
      for k in CameleonUtils.sortedKeys(res.fixtures)
        list.push {'id': k, 'v':res.fixtures[k]}
      $scope.cameleon.fixtureList = list
      promise.resolve()
    return promise

  $scope.getdevices = ()->
    promise = $q.defer()
    CameleonServer.GetDevices().$promise.then (res)->
      $scope.devices = res.devices
      list = []
      for k,v of res.devices
        list.push {'id': k, 'v':v}
      $scope.cameleon.machinesList = list
      promise.resolve()
    return promise

  # Init
  $scope.getdevices()
  $scope.getfixtures()

# This controller adds sounds
@SoundsCtrl = ($scope, CameleonServer,$upload,$modal,AlertUtils,MenuUtils,$q) ->

  $scope.getsounds = ()->
    promise = $q.defer()
    CameleonServer.GetSounds().$promise.then (res)->
      $scope.sounds = res.sounds
      list = []
      for k,v of res.sounds
        list.push {'id': k, 'v':v}
      $scope.soundlist = list
      promise.resolve()
    return promise

  $scope.updateSounds = (id, soundinfo)->
    #$scope.sounds[id] = {}
    #for e in soundinfo
    #  $scope.sounds[id][e.k] = e.v
    CameleonServer.UpdateSounds($scope.sounds).$promise.then (res)->
      AlertUtils.showMsg 'Updated !'

  $scope.createSound = ()->
     modalInstance = $modal.open(
       templateUrl: 'partials/ModalName.html'
       controller : NameCtrl,
       resolve :
          headerName : () -> 'Please enter sound name'
     )
     modalInstance.result.then (name)->
       $scope.addSound(name)


  $scope.addSound = (name)->
    $scope.sounds[name] =
      card: 0
      defLevel: 100
      loop: false
      position: 's'
      songFile: ''
      songName: ''

    CameleonServer.UpdateSounds($scope.sounds).$promise.then (evt)->
      $scope.getsounds().promise.then ()->
        $scope.soundEntry = MenuUtils.UpdateMenu($scope.soundlist,name)

  $scope.onFileSelect = ($files) ->
    i = 0
    while i < $files.length
      file = $files[i]
      #upload.php script, node.js route, or servlet url
      # or list of files: $files for html5 only
      # set the file formData name ('Content-Desposition'). Default is 'file'

      #fileFormDataName: myFile, //or a list of names for multiple files (html5).
      # customize how data is added to formData. See #40#issuecomment-28612000 for sample code

      #formDataAppender: function(formData, key, val){}
      $scope.upload = $upload.upload(
        url: "/cameleon/upload"
        file: file
      ).progress((evt) ->
        $scope.progressupload = parseInt(100.0 * evt.loaded / evt.total)
        return
      ).success((data, status, headers, config) ->
        # file is uploaded successfully
        console.log data
        $scope.soundEntry.v.songFile = data.name
        $scope.progessupload = 100
        return
      )
      i++
    return

  # Inits
  $scope.getsounds()

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
  $scope.LoadAllCameleon()

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
@SceneCtrl = ($scope, CameleonServer, MenuUtils,$modal,AlertUtils)->

  $scope.showCreate = false

    # As soon as the scope.settings changes, update the drop box menu.
  $scope.$watch 'cameleon.scenesList', (n,o) ->
      return if $scope.cameleon.currentScene == null
      $scope.cameleon.currentScene = MenuUtils.UpdateMenu($scope.cameleon.scenesList, $scope.cameleon.currentScene.id)

  $scope.showNew = ()->
    $scope.showCreate = true

  $scope.createScene =()->
     modalInstance = $modal.open(
       templateUrl: 'partials/ModalName.html'
       controller : NameCtrl,
       resolve :
          headerName : () -> 'Pleaser enter scene name'
     )
     modalInstance.result.then (name)->
       $scope.addScene(name)
     , (name)->

  $scope.addScene = (scene)->
    CameleonServer.CreateScene(scene).$promise.then (evt)->
        CameleonServer.GetSceneList().$promise.then (res)->
          $scope.cameleon.currentScene.id = scene
          $scope.cameleon.scenesList = res.list
          $scope.showCreate = false

  $scope.record = () ->
    CameleonServer.RecordScene($scope.cameleon.currentScene.id, $scope.cameleon.machines).$promise.then (evt)->
      AlertUtils.showMsg 'Scene recorded !'

  $scope.load = () ->
    return if $scope.cameleon.currentScene.id == null
    AlertUtils.showConfirm 'Do you want to load ?',()->
      $scope.LoadScene()
    , ()->
      AlertUtils.showMsg 'Beware you are updating an existing scene !'

@PicturesCtrl = ($scope, CameleonServer)->
  # Init
  $scope.LoadAllCameleon()
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
@PicturesMngrCtrl = ($scope, CameleonServer, MenuUtils,$modal,AlertUtils)->

    # As soon as the scope.settings changes, update the drop box menu.
  $scope.$watch 'cameleon.picturesList', (n,o) ->
      return if $scope.cameleon.currentPicture == null
      $scope.cameleon.currentPicture = MenuUtils.UpdateMenu($scope.cameleon.picturesList, $scope.cameleon.currentPicture.id)

  $scope.showNew = ()->
    $scope.showCreate = true

  $scope.createPicture =()->
     modalInstance = $modal.open(
       templateUrl: 'partials/ModalName.html'
       controller : NameCtrl,
       resolve :
          headerName : () -> 'Pleaser enter picture name'
     )
     modalInstance.result.then (name)->
       $scope.addPicture(name)
     , (name)->

  $scope.addPicture = (picture)->
    CameleonServer.CreatePicture(picture).$promise.then (evt)->
        CameleonServer.GetPicturesList().$promise.then (res)->
          $scope.cameleon.currentPicture.id = picture
          $scope.cameleon.picturesList = res.list
          $scope.showCreate = false

  $scope.record = () ->
    CameleonServer.RecordPicture($scope.cameleon.currentPicture.id, $scope.cameleon.picturesStuff).$promise.then (evt)->
      AlertUtils.showMsg 'Picture recorded !'

  $scope.load = () ->
    return if $scope.cameleon.currentPicture.id == null
    AlertUtils.showConfirm 'Do you want to load ?',()->
      $scope.LoadPicture()
    ,()->
      AlertUtils.showMsg 'Beware you are editing an existing picture !'

@CameleonCtrl = ($scope, CameleonServer)->
  # Init
  $scope.cameleon = {}

  $scope.LoadAllCameleon = ()->
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

  # Init
  $scope.LoadAllCameleon()

@MainCtrl = ($scope, $http, $q, $resource, sessionMngr,CameleonServer,AlertUtils)->
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

  $scope.turnoff = ()->
    CameleonServer.TurnOff().$promise.then (evt)->
      AlertUtils.showMsg "You can turn off power safely in about 1 minute"

  $scope.reboot = ()->
    CameleonServer.Reboot().$promise.then (evt)->
      AlertUtils.showMsg "You can refresh in a few minutes"

  $scope.reloadProfile = () ->
    ReloadProfile.get {}, () ->
      AlertUtils.showMsg 'Profiles loaded !'

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









