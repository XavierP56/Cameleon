app = angular.module 'myApp.Server', ['ngResource']

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

