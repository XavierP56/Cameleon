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
      templateUrl: '/sceniq/fold.html',
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
      scope: {
        id: '@',
        model: '@',
        channel: '@'
      },
      controller: function($scope, $resource) {
        var DmxEntry;
        DmxEntry = $resource('/dmx/entry', {}, {
          add: {
            method: 'POST'
          }
        });
        return DmxEntry.add({
          id: $scope.id,
          model: $scope.model,
          channel: $scope.channel
        }, function() {});
      }
    };
  });

  app.directive("dmxFader", function() {
    return {
      restrict: 'E',
      templateUrl: '/sceniq/dmxfader.html',
      scope: {
        id: '@',
        model: '@'
      },
      controller: function($scope, $resource) {
        var Query;
        Query = $resource('/dmx/query/:id');
        return $scope.started = Query.get({
          id: $scope.id
        }, function(res) {
          return $scope.dmx = res;
        });
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
      templateUrl: '/sceniq/soundbutton.html',
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
            return $scope.$parent.$$prevSibling.$emit('foldplay');
          });
          return $scope.$on('stop', function(sender, evt) {
            if (evt.id !== $scope.id) {
              return;
            }
            $scope.playing = false;
            $scope.classstyle = 'stopStyle';
            return $scope.$parent.$$prevSibling.$emit('foldstop');
          });
        });
      }
    };
  });

  this.RoomCtrl = function($scope, $http, $q, $resource) {
    var Events, Start;
    Events = $resource('/sounds/events');
    Start = $resource('/sounds/starts');
    $scope.getEvent = function() {
      return Events.get({}, function(evt) {
        if (evt.evt === 'play') {
          $scope.$broadcast('play', evt);
        }
        if (evt.evt === 'stop') {
          $scope.$broadcast('stop', evt);
        }
        return $scope.getEvent();
      });
    };
    return $scope.getEvent();
  };

}).call(this);

/*
//@ sourceMappingURL=sceniq.map
*/
