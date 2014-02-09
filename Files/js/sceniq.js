// Generated by CoffeeScript 1.6.3
(function() {
  var app;

  app = angular.module('myApp', ['ngResource', 'ui.router']);

  app.config(function($stateProvider) {
    var room1, room2;
    room1 = {
      url: "/Room1",
      templateUrl: "/sceniq/room1.html",
      controller: RoomCtrl
    };
    room2 = {
      url: "/Room2",
      templateUrl: "/sceniq/room2.html",
      controller: RoomCtrl
    };
    $stateProvider.state('room1', room1);
    return $stateProvider.state('room2', room2);
  });

  app.directive("fold", function() {
    return {
      restrict: 'E',
      templateUrl: '/sceniq/templates/fold.html',
      scope: {
        foldName: '@'
      },
      transclude: true,
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

  app.directive("dmxEntry", function() {
    return {
      restrict: 'E',
      templateUrl: '/sceniq/templates/dmxentry.html',
      scope: {
        id: '@',
        show: '='
      },
      controller: function($scope, $resource) {
        var Query, Update;
        Query = $resource('/dmx/getdefs/:id');
        Update = $resource('/dmx/setdefs', {}, {
          set: {
            method: 'POST'
          }
        });
        Query.get({
          id: $scope.id
        }, function(res) {
          $scope.entries = res.res;
        });
        return $scope.update = function() {
          Update.set({
            'id': $scope.id,
            'entries': $scope.entries
          }, function() {
            return alert('Channels updated !');
          });
        };
      }
    };
  });

  app.directive("dmxSlider", function() {
    return {
      restrict: 'E',
      templateUrl: '/sceniq/templates/dmxslider.html',
      scope: {
        id: '@',
        key: '@',
        def: '@',
        name: '@'
      },
      controller: function($scope, $resource) {
        var DmxSet, Query;
        Query = $resource('/dmx/query/:id/:key');
        DmxSet = $resource('/dmx/set', {}, {
          set: {
            method: 'POST'
          }
        });
        $scope.started = Query.get({
          id: $scope.id,
          key: $scope.key
        }, function(res) {
          $scope.value = res[$scope.key];
          return $scope.send();
        });
        $scope.send = function() {
          var cmd;
          cmd = {};
          cmd[$scope.key] = $scope.value;
          return DmxSet.set({
            id: $scope.id,
            cmds: cmd
          }, function() {});
        };
        return $scope.$on('update', function(sender, evt) {
          if ((evt.id !== $scope.id) || (evt.key !== $scope.key)) {
            return;
          }
          return $scope.value = evt.val;
        });
      }
    };
  });

  app.directive("dmxLight", function() {
    return {
      restrict: 'E',
      templateUrl: '/sceniq/templates/dmxlight.html',
      scope: {
        id: '@',
        preset: '@'
      },
      transclude: true,
      controller: function($scope, $resource) {
        $scope.cmds = {};
        $scope.DmxSet = $resource('/dmx/set', {}, {
          set: {
            method: 'POST'
          }
        });
        this.provide = function(k, v) {
          return $scope.cmds[k] = v;
        };
        $scope.light = function() {
          return $scope.DmxSet.set({
            id: $scope.id,
            cmds: $scope.cmds
          }, function() {});
        };
      }
    };
  });

  app.directive("dmxValue", function() {
    return {
      restrict: 'E',
      require: '^dmxLight',
      scope: {
        'key': '@',
        'value': '@'
      },
      link: function(scope, element, attrs, dmxLightCtrl) {
        return dmxLightCtrl.provide(attrs.key, attrs.value);
      }
    };
  });

  app.directive("soundButton", function() {
    return {
      restrict: 'E',
      scope: {
        songName: '@',
        id: '@',
        songFile: '@',
        height: '@',
        loop: '=?',
        defLevel: '=?'
      },
      templateUrl: '/sceniq/templates/soundbutton.html',
      controller: function($scope, $resource) {
        var Query, SoundLevel, SoundPlay, SoundStop;
        SoundPlay = $resource('/sounds/play', {}, {
          "do": {
            method: 'POST'
          }
        });
        SoundStop = $resource('/sounds/stop/:id');
        SoundLevel = $resource('/sounds/level/:id/:power');
        Query = $resource('/sounds/query/:id');
        $scope.loop = $scope.loop || false;
        $scope.defLevel = $scope.defLevel || 100;
        $scope.started = Query.get({
          id: $scope.id
        }, function(res) {
          var snd;
          $scope.playing = res.playing;
          if ($scope.playing === true) {
            $scope.classstyle = 'playStyle';
          }
          if ($scope.playing === true) {
            $scope.$parent.$$prevSibling.$emit('foldplay');
          }
          if ($scope.playing === false) {
            $scope.classstyle = 'stopStyle';
          }
          if (res.level != null) {
            snd = res.level;
          }
          if (res.level == null) {
            snd = $scope.defLevel;
          }
          return $scope.power = snd;
        });
        $scope.playSong = function() {
          return SoundPlay["do"]({
            id: $scope.id,
            repeat: $scope.loop,
            name: $scope.songFile,
            power: $scope.power
          }, function() {});
        };
        $scope.stopSong = function() {
          return SoundStop.get({
            id: $scope.id
          }, function() {});
        };
        $scope.doit = function() {
          if ($scope.playing === false) {
            $scope.playSong();
          }
          if ($scope.playing === true) {
            return $scope.stopSong();
          }
        };
        $scope.level = function() {
          return SoundLevel.get({
            id: $scope.id,
            power: $scope.power
          }, function() {});
        };
        return $scope.started.$promise.then(function() {
          $scope.$on('play', function(sender, evt) {
            if (evt.id !== $scope.id) {
              return;
            }
            $scope.playing = true;
            $scope.classstyle = 'playStyle';
            if ($scope.$parent.$$prevSibling !== null) {
              return $scope.$parent.$$prevSibling.$emit('foldplay');
            }
          });
          return $scope.$on('stop', function(sender, evt) {
            if (evt.id !== $scope.id) {
              return;
            }
            $scope.playing = false;
            $scope.classstyle = 'stopStyle';
            if ($scope.$parent.$$prevSibling !== null) {
              return $scope.$parent.$$prevSibling.$emit('foldstop');
            }
          });
        });
      }
    };
  });

  this.RoomCtrl = function($scope, $http, $q, $resource) {
    var DmxEvents, Events;
    Events = $resource('/sounds/events');
    DmxEvents = $resource('/dmx/events');
    $scope.getSoundEvent = function() {
      return Events.get({}, function(evt) {
        $scope.$broadcast(evt.evt, evt);
        return $scope.getSoundEvent();
      });
    };
    $scope.getDmxEvent = function() {
      return DmxEvents.get({}, function(evt) {
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
