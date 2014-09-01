# Controls the fader debug page.

app = angular.module 'faders', ['myApp.Server']

app.controller 'FaderCtrl' , ($scope, CameleonServer)->
  # Init of the controller.
  CameleonServer.GetMachinesList().$promise.then (res)->
    $scope.faderlist = res.list

