// Generated by CoffeeScript 1.6.3
(function() {
  var app;

  app = angular.module('myApp', ['ngResource', 'ui.router', 'JSONedit', 'ui.knob', 'ngCookies']);

  app.config(function($stateProvider) {
    var cameleon, cammachines, camscenes, confdrooms, config, drooms, faders, room1, room2, room3, room4, room5, room6, room7, room8;
    room1 = {
      url: "/Room1",
      templateUrl: "/profiles/room1.html",
      controller: RoomCtrl
    };
    room2 = {
      url: "/Room2",
      templateUrl: "/profiles/room2.html",
      controller: RoomCtrl
    };
    room3 = {
      url: "/Room3",
      templateUrl: "/profiles/room3.html",
      controller: RoomCtrl
    };
    room4 = {
      url: "/Room4",
      templateUrl: "/profiles/room4.html",
      controller: RoomCtrl
    };
    room5 = {
      url: "/Room5",
      templateUrl: "/profiles/room5.html",
      controller: RoomCtrl
    };
    room6 = {
      url: "/Room6",
      templateUrl: "/profiles/room6.html",
      controller: RoomCtrl
    };
    room7 = {
      url: "/Room7",
      templateUrl: "/profiles/room7.html",
      controller: RoomCtrl
    };
    room8 = {
      url: "/Room8",
      templateUrl: "/profiles/room8.html",
      controller: RoomCtrl
    };
    config = {
      url: "/Config",
      templateUrl: "/sceniq/config.html",
      controller: ConfigCtrl
    };
    faders = {
      url: "/Fader",
      templateUrl: "/sceniq/fadercfg.html",
      controller: FaderCtrl
    };
    confdrooms = {
      url: "/CRoom",
      templateUrl: "/sceniq/dconf.html",
      controller: ConfigRoomCtrl
    };
    drooms = {
      url: "/DRooms",
      templateUrl: "/sceniq/drooms.html",
      controller: ConfigRoomCtrl
    };
    cameleon = {
      url: '/Cameleon',
      templateUrl: "/sceniq/cameleon.html",
      controller: CameleonCtrl
    };
    cammachines = {
      url: '/machines',
      templateUrl: 'partials/machines.html',
      controller: CamMachinesCtrl
    };
    camscenes = {
      'url': '/associate',
      views: {
        '': {
          templateUrl: 'partials/asso.html'
        },
        'assettings@cameleon.associate': {
          templateUrl: 'partials/associate.html',
          controller: CamAssociateCtrl
        },
        'scenes@cameleon.associate': {
          templateUrl: 'partials/scenes.html',
          controller: SceneCtrl
        }
      }
    };
    $stateProvider.state('room1', room1);
    $stateProvider.state('room2', room2);
    $stateProvider.state('room3', room3);
    $stateProvider.state('room4', room4);
    $stateProvider.state('room5', room5);
    $stateProvider.state('room6', room6);
    $stateProvider.state('room7', room7);
    $stateProvider.state('room8', room8);
    $stateProvider.state('config', config);
    $stateProvider.state('faders', faders);
    $stateProvider.state('confdrooms', confdrooms);
    $stateProvider.state('drooms', drooms);
    $stateProvider.state('cameleon', cameleon);
    $stateProvider.state('cameleon.machines', cammachines);
    return $stateProvider.state('cameleon.associate', camscenes);
  });

  app.factory('sessionMngr', function() {
    var mngr;
    mngr = {
      'connected': false
    };
    mngr.IsConnected = function() {
      return mngr.connected;
    };
    mngr.SetConnected = function(sessionId) {
      mngr.connected = true;
      return mngr.sessionId = sessionId;
    };
    return mngr;
  });

  app.factory('configMngr', function($resource) {
    var Query, datas;
    datas = {};
    Query = $resource('/cfg/getsettinglist');
    datas.LoadSettingsList = function() {
      return Query.get({}, function(res) {
        return datas.settingLst = res.settings;
      });
    };
    datas.GetSettingList = function() {
      return datas.settingLst;
    };
    return datas;
  });

  app.factory('CameleonServer', function($resource) {
    var datas, _CreateScene, _DmxSet, _FaderList, _GetSceneList, _LoadScene, _QuerySlider, _RecordScene, _RecordSetting, _SetFader, _SettingList, _SlidersList;
    datas = {};
    _SettingList = $resource('/cfg/getsettinglist');
    _FaderList = $resource('/dmx/getfaderlist');
    _SlidersList = $resource('/dmx/faders/:id');
    _SetFader = $resource('/dmx/setfader', {}, {
      set: {
        method: 'POST'
      }
    });
    _QuerySlider = $resource('/dmx/query/:id/:key');
    _DmxSet = $resource('/dmx/set', {}, {
      set: {
        method: 'POST'
      }
    });
    _RecordSetting = $resource('/dmx/recordsetting/:fader/:setname');
    _GetSceneList = $resource('/cameleon/getscenelist');
    _CreateScene = $resource('/cameleon/createscene/:scene');
    _RecordScene = $resource('/cameleon/recordscene', {}, {
      set: {
        method: 'POST'
      }
    });
    _LoadScene = $resource('/cameleon/loadscene/:scene');
    datas.GetMachinesList = function() {
      return _FaderList.get({});
    };
    datas.GetSettingList = function() {
      return _SettingList.get({});
    };
    datas.GetSliderList = function(id) {
      return _SlidersList.get({
        id: id
      });
    };
    datas.SetFaderSetting = function(fader, setting) {
      return _SetFader.set({
        id: fader,
        setting: setting
      });
    };
    datas.QuerySlider = function(id, key) {
      return _QuerySlider.get({
        id: id,
        key: key
      });
    };
    datas.SetSliderCmd = function(id, cmds) {
      return _DmxSet.set({
        id: id,
        cmds: cmds
      });
    };
    datas.RecordFaderSetting = function(fader, setname) {
      return _RecordSetting.get({
        fader: fader,
        setname: setname
      });
    };
    datas.GetSceneList = function() {
      return _GetSceneList.get({});
    };
    datas.CreateScene = function(scene) {
      return _CreateScene.get({
        scene: scene
      });
    };
    datas.RecordScene = function(scene, machines) {
      return _RecordScene.set({
        scene: scene,
        machines: machines
      });
    };
    datas.LoadScene = function(scene) {
      return _LoadScene.get({
        scene: scene
      });
    };
    return datas;
  });

  app.directive("widgets", function() {
    return {
      restrict: 'E',
      templateUrl: '/sceniq/templates/widgets.html',
      scope: {
        stuff: '=things'
      },
      link: function(scope, elemt, attrs) {}
    };
  });

  app.directive("fold", function() {
    return {
      restrict: 'E',
      templateUrl: '/sceniq/templates/fold.html',
      scope: {
        foldName: '@'
      },
      transclude: true,
      compile: function(element, attr, linker) {
        return {
          pre: function(scope, element, attr) {
            return linker(scope, function(clone) {
              element.children().eq(1).append(clone);
            });
          }
        };
      },
      controller: function($scope) {
        $scope.nb = 0;
        $scope.$on('foldplay', function(sender, evt) {
          return $scope.nb = $scope.nb + 1;
        });
        return $scope.$on('foldstop', function(sender, evt) {
          return $scope.nb = $scope.nb - 1;
        });
      }
    };
  });

  app.directive("dmxSlider", function(CameleonServer) {
    return {
      restrict: 'E',
      templateUrl: '/sceniq/templates/dmxslider.html',
      scope: true,
      link: function(scope, elemt, attrs) {
        scope.started = function() {
          return CameleonServer.QuerySlider(scope.id, scope.key).$promise.then(function(res) {
            scope.value = res[scope.key];
            scope.knobOptions = res['knob'];
            scope.$on('update', function(sender, evt) {
              if ((evt.id !== scope.id) || (evt.key !== scope.key)) {
                return;
              }
              return scope.value = evt.val;
            });
            return scope.showMe = true;
          });
        };
        scope.send = function() {
          var cmd;
          cmd = {};
          cmd[scope.key] = scope.value;
          return CameleonServer.SetSliderCmd(scope.id, cmd).$promise.then(function() {
            return scope.$emit('sliderChanged', {
              'id': scope.id
            });
          });
        };
        scope.showMe = true;
        scope.id = attrs.id;
        scope.key = attrs.key;
        scope.def = attrs.def;
        scope.name = attrs.name;
        return scope.started();
      }
    };
  });

  app.directive("dmxLight", function() {
    return {
      restrict: 'E',
      templateUrl: '/sceniq/templates/dmxlight.html',
      scope: {
        id: '@'
      },
      controller: function($scope, $resource) {
        var DmxSetLight, LightQuery;
        LightQuery = $resource('/dmx/light/:id');
        DmxSetLight = $resource('/dmx/setLight/:light');
        LightQuery.get({
          id: $scope.id
        }, function(res) {
          $scope.light = res.light;
          if ($scope.light.hasOwnProperty('transition')) {
            if ($scope.light.transition === "False") {
              $scope.dmxstyle = 'dmx';
            }
            if ($scope.light.transition === "True") {
              $scope.dmxstyle = 'transit';
            }
          } else {
            $scope.dmxstyle = 'list';
          }
          if (res.active === true) {
            return $scope.active = "running";
          }
        });
        $scope["do"] = function() {
          return DmxSetLight.get({
            light: $scope.id
          }, function(res) {});
        };
        $scope.$on('activeLight', function(sender, evt) {
          if (evt.group !== $scope.light.group) {
            return;
          }
          if (evt.light !== $scope.id) {
            return $scope.active = null;
          } else {
            return $scope.active = "running";
          }
        });
      }
    };
  });

  app.directive("dmxFader", function(CameleonServer, $resource, $parse) {
    return {
      restrict: 'E',
      scope: true,
      templateUrl: '/sceniq/templates/dmxfader.html',
      link: function(scope, elemt, attrs) {
        var Generate;
        Generate = $resource('/dmx/generate/:fader/:setting/:prefix');
        scope.record = function(fader, wrapper) {
          if ((wrapper === void 0) || (wrapper === '')) {
            return alert('You must enter a setting name !');
          } else {
            return CameleonServer.RecordFaderSetting(scope.id, wrapper.name).$promise.then(function(evt) {
              return CameleonServer.GetSettingList().$promise.then(function(res) {
                scope.settings = res.settings;
                scope.currentSetting = wrapper.name;
                return wrapper.name = "";
              });
            });
          }
        };
        scope.showMe = function() {
          if (scope.settings === void 0) {
            return false;
          }
          return true;
        };
        scope.computeCssClass = function(last) {
          if (last === true) {
            return null;
          } else {
            return "leftpos";
          }
        };
        scope.$watch('currentSetting', function(n, o) {
          if (n === o) {
            return;
          }
          $parse(attrs.settingChanged)(scope, {
            newSetting: n
          });
          if (n === '') {
            return;
          }
          return CameleonServer.SetFaderSetting(scope.id, n);
        });
        scope.SetSetting = function(fader, setting) {
          return scope.currentSetting = setting;
        };
        scope.RefreshDropBox = function() {
          var ix, n, _i, _len, _ref;
          if (scope.settings === void 0) {
            return;
          }
          ix = 0;
          _ref = scope.settings;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            n = _ref[_i];
            if (n.name === scope.currentSetting) {
              break;
            } else {
              ix++;
            }
          }
          return scope.setting.menu = scope.settings[ix];
        };
        scope.setting = {};
        scope.setting.menu = {
          'name': 'me'
        };
        scope.currentSetting = '';
        scope.InitMenu = function() {
          return scope.setting.menu = scope.settings[0];
        };
        scope.$watch('settings', function(n, o) {
          return scope.RefreshDropBox();
        });
        attrs.$observe('id', function(v) {
          if (v === '') {
            return;
          }
          scope.id = v;
          CameleonServer.GetSliderList(v).$promise.then(function(res) {
            scope.sliders = res.res;
            return scope.showIt = true;
          });
          return CameleonServer.GetSettingList().$promise.then(function(res) {
            return scope.settings = res.settings;
          });
        });
        scope.$on('setFaderSetting', function(sender, evt) {
          if (evt.id !== scope.id) {
            return;
          }
          if (evt.setting !== scope.currentSetting) {
            scope.currentSetting = evt.setting;
            return scope.RefreshDropBox();
          }
        });
        scope.$on('sliderChanged', function(sender, evt) {
          if (scope.id !== evt.id) {
            return;
          }
          scope.currentSetting = '';
          return scope.RefreshDropBox();
        });
        return scope.showIt = false;
      }
    };
  });

  app.directive("soundButton", function($resource) {
    return {
      restrict: 'E',
      templateUrl: '/sceniq/templates/soundbutton.html',
      scope: true,
      link: function(scope, elemt, attrs) {
        var Query, SoundLevel, SoundPlay, SoundStop;
        scope.power = 100;
        SoundPlay = $resource('/sounds/play', {}, {
          "do": {
            method: 'POST'
          }
        });
        SoundStop = $resource('/sounds/stop/:id');
        SoundLevel = $resource('/sounds/level/:id/:power');
        Query = $resource('/sounds/query/:id');
        scope.showMe = false;
        scope.started = function() {
          return Query.get({
            id: scope.id
          }, function(res) {
            var snd;
            scope.song = res.defs;
            scope.playing = res.playing;
            if (scope.playing === true) {
              scope.classstyle = 'playStyle';
            }
            if (scope.playing === true) {
              scope.$emit('foldplay');
            }
            if (scope.playing === false) {
              scope.classstyle = 'stopStyle';
            }
            if (res.level != null) {
              snd = res.level;
            }
            if (res.level == null) {
              snd = res.defs.defLevel;
            }
            scope.power = snd;
            scope.knobOptions = res.knob;
            scope.$on('play', function(sender, evt) {
              if (evt.id !== scope.id) {
                return;
              }
              scope.playing = true;
              scope.classstyle = 'playStyle';
              return scope.$emit('foldplay');
            });
            scope.$on('stop', function(sender, evt) {
              if (evt.id !== scope.id) {
                return;
              }
              scope.playing = false;
              scope.classstyle = 'stopStyle';
              return scope.$emit('foldstop');
            });
            scope.$on('volumeUpt', function(sender, evt) {
              if (evt.id !== scope.id) {
                return;
              }
              return scope.power = evt.power;
            });
            return scope.showMe = true;
          });
        };
        scope.playSong = function() {
          var cmd;
          cmd = {
            id: scope.id,
            repeat: scope.song.loop,
            name: scope.song.songFile,
            power: scope.power,
            position: scope.song.position,
            card: scope.song.card
          };
          return SoundPlay["do"](cmd, function() {});
        };
        scope.stopSong = function() {
          return SoundStop.get({
            id: scope.id
          }, function() {});
        };
        scope.doit = function() {
          if (scope.playing === false) {
            scope.playSong();
          }
          if (scope.playing === true) {
            return scope.stopSong();
          }
        };
        scope.level = function() {
          return SoundLevel.get({
            id: scope.id,
            power: scope.power
          }, function() {});
        };
        scope.mute = function() {
          if (scope.power > 0) {
            scope.muted = scope.power;
            scope.power = 0;
          } else {
            scope.power = scope.muted;
            scope.muted = 0;
          }
          scope.level();
        };
        scope.id = attrs.id;
        return scope.started();
      }
    };
  });

  this.RoomCtrl = function($scope, $http, $q, $resource) {};

  this.ConfigCtrl = function($scope, $http, $q, $resource) {
    var Query, Save, Update;
    Query = $resource('/models/getdefs', {}, {
      set: {
        method: 'POST'
      }
    });
    Update = $resource('/models/setdefs', {}, {
      set: {
        method: 'POST'
      }
    });
    Save = $resource('/models/save');
    $scope.update = function() {
      var cmd;
      cmd = {
        'dmx_model': $scope.dmxModel,
        'dmx_setting': $scope.dmxSetting,
        'snd_setting': $scope.sndSetting,
        'dmx_light': $scope.dmxLight,
        'dmx_group': $scope.dmxGroup,
        'dmx_fixtures': $scope.dmxFixtures
      };
      Update.set(cmd, function() {});
      return alert('Settings updated !');
    };
    $scope.save = function() {
      var cmd;
      cmd = {
        'dmx_model': $scope.dmxModel,
        'dmx_setting': $scope.dmxSetting,
        'snd_setting': $scope.sndSetting,
        'dmx_light': $scope.dmxLight,
        'dmx_group': $scope.dmxGroup,
        'dmx_fixtures': $scope.dmxFixtures
      };
      $scope.setDone = Update.set(cmd, function() {});
      return $scope.setDone.$promise.then(function() {
        return Save.get({}, function() {
          return alert('Settings saved !');
        });
      });
    };
    Query.set({}, function(res) {
      $scope.dmxModel = res.dmx_model;
      $scope.dmxGroup = res.dmx_group;
      $scope.dmxSetting = res.dmx_setting;
      $scope.dmxLight = res.dmx_light;
      $scope.sndSetting = res.snd_setting;
      $scope.dmxFixtures = res.dmx_fixtures;
    });
    return $scope.$on('$stateChangeStart', function(event) {});
  };

  app.filter('faderFilter', function() {
    return function(input, low, high) {
      if ((low !== void 0) && (high !== void 0)) {
        return input.slice(low, +high + 1 || 9e9);
      } else {
        return input;
      }
    };
  });

  this.FaderCtrl = function($scope, CameleonServer) {
    return CameleonServer.GetMachinesList().$promise.then(function(res) {
      return $scope.faderlist = res.list;
    });
  };

  this.ConfigRoomCtrl = function($scope, $http, $q, $resource) {
    var Load, Save;
    $scope.scenes = {};
    Save = $resource('/models/saveDrooms', {}, {
      set: {
        method: 'POST'
      }
    });
    Load = $resource('/models/loadDrooms');
    $scope.current = '';
    $scope.setting = {};
    $scope.InitMenu = function() {
      var ix, keys, n, scene, _i, _j, _len, _len1, _ref;
      $scope.list = [];
      keys = Object.keys($scope.scenes).sort();
      for (_i = 0, _len = keys.length; _i < _len; _i++) {
        scene = keys[_i];
        $scope.list.push({
          'name': scene
        });
      }
      ix = 0;
      _ref = $scope.list;
      for (_j = 0, _len1 = _ref.length; _j < _len1; _j++) {
        n = _ref[_j];
        if (n.name === $scope.current) {
          break;
        } else {
          ix++;
        }
      }
      return $scope.setting.scene = $scope.list[ix];
    };
    $scope.update = function(name) {
      return $scope.stuff = angular.copy($scope.scenes[name]);
    };
    $scope.refresh = function(name) {
      $scope.InitMenu();
      return $scope.update(name);
    };
    $scope.SetScene = function(scene) {
      $scope.current = scene.name;
      return $scope.update($scope.current);
    };
    $scope.save = function() {
      var cmd;
      cmd = {
        'drooms': $scope.scenes
      };
      $scope.setDone = Save.set(cmd, function() {});
      return $scope.setDone.$promise.then(function() {
        return alert('Dynamic Rooms saved !');
      });
    };
    $scope.reload = function() {
      return Load.get(function(res) {
        $scope.scenes = res.drooms;
        return $scope.refresh($scope.current);
      });
    };
    return Load.get(function(res) {
      $scope.scenes = res.drooms;
      return $scope.InitMenu();
    });
  };

  this.CamMachinesCtrl = function($scope, CameleonServer) {
    $scope.findMachine = function(id) {
      var ix, m, _i, _len, _ref;
      ix = 0;
      _ref = $scope.cameleon.machines;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        m = _ref[_i];
        if (m.id === id) {
          return ix;
        }
        ix++;
      }
      return -1;
    };
    CameleonServer.GetMachinesList().$promise.then(function(res) {
      $scope.cameleon.machinesList = res.list;
      return $scope.cameleon.currentMachine = $scope.cameleon.machinesList[0];
    });
    $scope.addMachine = function(currentMachine) {
      var index;
      index = $scope.findMachine(currentMachine.id);
      if (index !== -1) {
        return;
      }
      currentMachine.setting = '';
      $scope.cameleon.machines.push(currentMachine);
    };
    return $scope.removeMachine = function(currentMachine) {
      var index;
      index = $scope.findMachine(currentMachine.id);
      if (index === -1) {
        return;
      }
      $scope.cameleon.machines.splice(index, 1);
    };
  };

  this.CamAssociateCtrl = function($scope, CameleonServer) {
    $scope.cameleon.curMachine = {};
    $scope.selectMachine = function(machine) {
      $scope.cameleon.curMachine = machine;
      return CameleonServer.SetFaderSetting(machine.id, machine.setting);
    };
    return $scope.update_setting = function(newSetting) {
      var m, _i, _len, _ref, _results;
      _ref = $scope.cameleon.machines;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        m = _ref[_i];
        if (m === $scope.cameleon.curMachine) {
          _results.push(m.setting = newSetting);
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };
  };

  this.SceneCtrl = function($scope, CameleonServer) {
    $scope.$watch('cameleon.scenesList', function(n, o) {
      var ix, _i, _len, _ref;
      ix = 0;
      _ref = $scope.cameleon.scenesList;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        n = _ref[_i];
        if (n.id === $scope.cameleon.currentScene.id) {
          break;
        } else {
          ix++;
        }
      }
      return $scope.cameleon.currentScene = $scope.cameleon.scenesList[ix];
    });
    $scope.addScene = function(scene) {
      return CameleonServer.CreateScene(scene).$promise.then(function(evt) {
        return CameleonServer.GetSceneList().$promise.then(function(res) {
          $scope.cameleon.currentScene.id = scene;
          return $scope.cameleon.scenesList = res.list;
        });
      });
    };
    $scope.record = function() {
      return CameleonServer.RecordScene($scope.cameleon.currentScene.id, $scope.cameleon.machines).$promise.then(function(evt) {
        return alert('Scene recorded !');
      });
    };
    return $scope.load = function() {
      var r;
      if ($scope.cameleon.currentScene.id === null) {
        return;
      }
      r = window.confirm('Do you want to load ?');
      if (r === true) {
        alert('Load Scene !');
        return $scope.$emit('loadScene');
      }
    };
  };

  this.CameleonCtrl = function($scope, CameleonServer) {
    $scope.cameleon = {};
    $scope.cameleon.machines = [];
    $scope.cameleon.currentScene = {
      id: null,
      name: ''
    };
    CameleonServer.GetSceneList().$promise.then(function(res) {
      return $scope.cameleon.scenesList = res.list;
    });
    return $scope.$on('loadScene', function(sender, evt) {
      return CameleonServer.LoadScene($scope.cameleon.currentScene.id).$promise.then(function(res) {
        return $scope.cameleon.machines = res.load.list;
      });
    });
  };

  this.MainCtrl = function($scope, $http, $q, $resource, sessionMngr) {
    var CreateSession, DmxCancel, DmxEvents, DmxPanic, Events, Query, ReloadProfile, SndCancel, SndPanic, dmxpromise, sndpromise;
    SndPanic = $resource('/sounds/panic');
    DmxPanic = $resource('/dmx/panic');
    Query = $resource('/models/scenes');
    CreateSession = $resource('/scenic/newsession');
    ReloadProfile = $resource('/cfg/reloadprofiles');
    Query.get({}, function(res) {
      return $scope.entries = res.scenes;
    });
    if (!sessionMngr.IsConnected()) {
      CreateSession.get({}, function(res) {
        sessionMngr.SetConnected(res.id);
        return $http.defaults.headers.post['SessionId'] = res.id;
      });
    }
    $scope.soundPanic = function() {
      return SndPanic.get({}, function() {});
    };
    $scope.dmxPanic = function() {
      return DmxPanic.get({}, function() {});
    };
    SndCancel = $q.defer();
    DmxCancel = $q.defer();
    sndpromise = SndCancel.promise;
    sndpromise.then(function() {});
    dmxpromise = DmxCancel.promise;
    dmxpromise.then(function() {});
    $scope.reloadProfile = function() {
      return ReloadProfile.get({}, function() {
        return alert('Profiles loaded !');
      });
    };
    Events = $resource('/sounds/events', {}, {
      'get': {
        method: 'POST',
        timeout: sndpromise
      }
    });
    DmxEvents = $resource('/dmx/events', {}, {
      'get': {
        method: 'POST',
        timeout: dmxpromise
      }
    });
    $scope.getSoundEvent = function() {
      $scope.promiseGetSnd = Events.get({});
      return $scope.promiseGetSnd.$promise.then(function(evt) {
        $scope.$broadcast(evt.evt, evt);
        return $scope.getSoundEvent();
      });
    };
    $scope.getDmxEvent = function() {
      $scope.promiseGetDmx = DmxEvents.get({});
      return $scope.promiseGetDmx.$promise.then(function(evt) {
        $scope.$broadcast(evt.evt, evt);
        return $scope.getDmxEvent();
      });
    };
    $scope.getSoundEvent();
    return $scope.getDmxEvent();
  };

}).call(this);

/*
//@ sourceMappingURL=sceniq.map
*/
