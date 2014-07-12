angular.module 'adventure-main', ['ngRoute', 'adventure-services']

  .config ($routeProvider) ->
    $routeProvider
      .when '/',
        templateUrl: 'main/main.html'
        controller: 'MainCtrl as ctrl'

  .controller 'MainCtrl', (processInput, player, world) ->
    compare = (name) -> (item) -> item.name.toLowerCase() == name
    return {
      area: world.area player.position
      userAction: (inputText) ->
        return if _.isEmpty inputText.trim()
        command = processInput inputText

        if command.error
          @error = command.message
          return

        @error = ''

        switch command.type
          when 'move'
            if @area.hasExit command.direction
              @area = world.area command.destination
              @status = "You walk #{ command.direction }"
              console.dir @area
              player.position = command.destination
            else
              @status = "Cannot go #{ command.direction }"
          when 'inspect'
            if command.object?
              object = _.find @area.items, compare command.object
              @status = object?.description or "Can't see #{ command.object }"
            else
              @status = 'Inspect what?'
          else throw new Error 'Unknown command type'
    }

