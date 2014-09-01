# Controls the fader debug page.

@FaderCtrl = ($scope, CameleonServer)->
  # Init of the controller.
  CameleonServer.GetMachinesList().$promise.then (res)->
    $scope.faderlist = res.list

