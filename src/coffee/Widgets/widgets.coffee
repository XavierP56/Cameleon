app = angular.module 'widgets', ['myApp.Server', 'utils']

# Display the various dynamic buttons.
app.directive "widgets", (MenuUtils) ->
  restrict: 'E'
  templateUrl: '/sceniq/templates/widgets.html'
  scope : true

  link: (scope, elemt, attrs) ->

    scope.visibleList = {}

    scope.init = (index)->
      scope.visibleList[index] = false

    scope.toggleEdit = (index)->
      for k of scope.visibleList
        scope.visibleList[k] = false
      scope.visibleList[index] = !scope.visibleList[index]

    scope.showMe = (index)->
      scope.visibleList[index]

    scope.forward = (index)->
      scope.stuff.move(index, index+1)
      scope.toggleEdit(index+1)

    scope.backward = (index)->
      scope.stuff.move(index, index-1) if index > 0
      if index == 0
        scope.toggleEdit(0)
      else
        scope.toggleEdit(index-1)

    scope.separator = (index)->
      scope.stuff.splice(index,0,{'msg':'', 'type':'line'})
      scope.toggleEdit(index+1)

    scope.remove = (index)->
      scope.stuff.splice(index, 1)
      scope.toggleEdit(index+1)

    scope.setStart = (stuff, wrapper)->
      stuff.startSong = wrapper.entry.id

    scope.getStartSound = (stuff, wrapper)->
      return if scope.edit == false
      if 'startSong' of stuff
        wrapper.entry = MenuUtils.UpdateMenu(scope.cameleon.associatesoundslist,stuff.startSong)

    scope.editMe =
    # Init
    scope.$watch attrs.things, (n,o)->
      scope.stuff = n

    if 'edit' of attrs
      scope.$watch attrs.edit, (n,o)->
        scope.edit = n
    else
        scope.edit = false
    return
