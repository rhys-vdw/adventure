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

        console.dir command

        if command.error
          @error = command.message
          return

        @error = ''

        if command.type == 'go'
          if @area.hasExit command.direction
            @area = world.area command.destination
            @status = "You walk #{ command.direction }"
            console.dir @area
            player.position = command.destination
          else
            @status = "Cannot go #{ command.direction }"
        else
          if command.object?
            object = _.find @area.items, compare command.object
            if ! object?
              @status = "Can't see #{ command.object }"
            else
              if command.type == 'inspect'
                @status = object?.description
              else if _(object.actions).contains command.type
                @status = "#{ command.type } the #{ command.object }"
              else
                throw new Error 'Unknown command type'
          else
            @status = "#{ command.type } what?"
    }

