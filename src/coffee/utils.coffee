app = angular.module 'utils', ['myApp.Server']

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

Array::move = (old_index, new_index) ->
  @splice new_index, 0, @splice(old_index, 1)[0]
