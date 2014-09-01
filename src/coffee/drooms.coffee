# DRoomsCtrl
# Controller for "Pictures"
# Display the list of widgets.

@DRoomsCtrl = ($scope, CameleonServer)->
  $scope.cameleon = {}
  $scope.timerRunning = false

  CameleonServer.GetPicturesList().$promise.then (res)->
    $scope.cameleon.picturesList = res.list

  $scope.load = ()->
      CameleonServer.LoadPicture($scope.cameleon.currentPicture.id).$promise.then (res)->
        $scope.cameleon.picturesStuff = res.load.list

  $scope.startTimer =  ()->
      return if $scope.timerRunning == true
      $scope.$broadcast('timer-start')
      $scope.timerRunning = true;

  $scope.stopTimer =  ()->
      return if $scope.timerRunning == false
      $scope.$broadcast('timer-stop')
      $scope.timerRunning = false