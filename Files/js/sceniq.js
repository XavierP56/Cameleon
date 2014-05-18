// Generated by CoffeeScript 1.6.3
(function() {
  var FaderCtrl, app;

  app = angular.module('myApp', ['ngResource', 'ui.router', 'JSONedit', 'ui.knob', 'ngCookies']);

  app.config(function($stateProvider) {
    var config, faders, room1, room2, room3, room4, room5, room6, room7, room8;
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
    $stateProvider.state('room1', room1);
    $stateProvider.state('room2', room2);
    $stateProvider.state('room3', room3);
    $stateProvider.state('room4', room4);
    $stateProvider.state('room5', room5);
    $stateProvider.state('room6', room6);
    $stateProvider.state('room7', room7);
    $stateProvider.state('room8', room8);
    $stateProvider.state('config', config);
    return $stateProvider.state('faders', faders);
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
    datas.GetSettingsList = function() {
      return Query.get({});
    };
    return datas;
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

  app.directive("dmxSlider", function($resource) {
    return {
      restrict: 'E',
      templateUrl: '/sceniq/templates/dmxslider.html',
      scope: true,
      link: function(scope, elemt, attrs) {
        var DmxSet, Query;
        Query = $resource('/dmx/query/:id/:key');
        DmxSet = $resource('/dmx/set', {}, {
          set: {
            method: 'POST'
          }
        });
        scope.started = function() {
          return Query.get({
            id: scope.id,
            key: scope.key
          }, function(res) {
            scope.value = res[scope.key];
            scope.send();
            scope.knobOptions = res['knob'];
            return scope.$on('update', function(sender, evt) {
              if ((evt.id !== scope.id) || (evt.key !== scope.key)) {
                return;
              }
              return scope.value = evt.val;
            });
          });
        };
        scope.send = function() {
          var cmd;
          cmd = {};
          cmd[scope.key] = scope.value;
          return DmxSet.set({
            id: scope.id,
            cmds: cmd
          }, function() {});
        };
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
      transclude: true,
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

  app.directive("dmxFader", function() {
    return {
      restrict: 'E',
      scope: {
        id: '@'
      },
      templateUrl: '/sceniq/templates/dmxfader.html',
      controller: function($scope, $resource) {
        var Sliders;
        Sliders = $resource('/dmx/faders/:id');
        Sliders.get({
          id: $scope.id
        }, function(res) {
          return $scope.sliders = res.res;
        });
        return $scope.computeCssClass = function(last) {
          if (last === true) {
            return null;
          } else {
            return "leftpos";
          }
        };
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
            return scope.$on('stop', function(sender, evt) {
              if (evt.id !== scope.id) {
                return;
              }
              scope.playing = false;
              scope.classstyle = 'stopStyle';
              return scope.$emit('foldstop');
            });
          });
        };
        scope.playSong = function() {
          return SoundPlay["do"]({
            id: scope.id,
            repeat: scope.song.loop,
            name: scope.song.songFile,
            power: scope.power,
            position: scope.song.position,
            card: scope.song.card
          }, function() {});
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
    Query = $resource('/models/getdefs');
    Update = $resource('/models/setdefs', {}, {
      set: {
        method: 'POST'
      }
    });
    Save = $resource('/models/save');
    $scope.update = function() {
      Update.set({
        'dmx_model': $scope.dmxModel,
        'dmx_setting': $scope.dmxSetting,
        'snd_setting': $scope.sndSetting,
        "dmx_light": $scope.dmxLight
      }, function() {});
      return alert('Settings updated !');
    };
    $scope.save = function() {
      $scope.setDone = Update.set({
        'dmx_model': $scope.dmxModel,
        'dmx_setting': $scope.dmxSetting,
        'snd_setting': $scope.sndSetting,
        "dmx_light": $scope.dmxLight
      }, function() {});
      return $scope.setDone.$promise.then(function() {
        return Save.get({}, function() {
          return alert('Settings saved !');
        });
      });
    };
    Query.get({}, function(res) {
      $scope.dmxModel = res.dmx_model;
      $scope.dmxGroup = res.dmx_group;
      $scope.dmxSetting = res.dmx_setting;
      $scope.dmxLight = res.dmx_light;
      $scope.sndSetting = res.snd_setting;
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

  FaderCtrl = function($scope, $http, $q, $resource, configMngr) {
    var FaderList, RecordSetting, SetFader;
    FaderList = $resource('/dmx/getfaderlist');
    SetFader = $resource('/dmx/setfader/:fader/:setting');
    RecordSetting = $resource('/dmx/recordsetting/:fader');
    $scope.settingList = [];
    $scope.SetSetting = function(fader, setting) {
      return SetFader.get({
        fader: fader,
        setting: setting.lapin.name
      });
    };
    $scope.record = function(fader, setting) {
      return RecordSetting.get({
        fader: fader
      }, function(res) {
        var set_promise;
        set_promise = configMngr.GetSettingsList();
        return set_promise.$promise.then(function(setv) {
          var ix, n, _i, _len, _ref;
          $scope.settingList = setv.settings;
          ix = 0;
          _ref = $scope.settingList;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            n = _ref[_i];
            if (n.name === res.name) {
              break;
            } else {
              ix++;
            }
          }
          setting.lapin = $scope.settingList[ix];
          return alert(res.msg);
        });
      });
    };
    FaderList.get({}, function(res) {
      var set_promise;
      $scope.faderlist = res.list;
      set_promise = configMngr.GetSettingsList();
      return set_promise.$promise.then(function(res) {
        return $scope.settingList = res.settings;
      });
    });
  };

  this.MainCtrl = function($scope, $http, $q, $resource, sessionMngr) {
    var CreateSession, DmxCancel, DmxEvents, Events, Query, SndCancel, SndPanic, dmxpromise, sndpromise;
    SndPanic = $resource('/sounds/panic');
    Query = $resource('/models/scenes');
    CreateSession = $resource('/scenic/newsession');
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
    SndCancel = $q.defer();
    DmxCancel = $q.defer();
    sndpromise = SndCancel.promise;
    sndpromise.then(function() {});
    dmxpromise = DmxCancel.promise;
    dmxpromise.then(function() {});
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
