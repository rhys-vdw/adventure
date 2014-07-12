angular.module 'adventure-main', ['ngRoute', 'adventure-services']

  .config ($routeProvider) ->
    $routeProvider
      .when '/',
        templateUrl: 'main/main.html'
        controller: 'MainCtrl as ctrl'

  .controller 'MainCtrl', (processInput, player, world) ->
    area: world.area player.position
    userAction: (inputText) ->
      command = processInput inputText

      if command.error
        @error = command.message
        return

      @error = ''

      switch command.type
        when 'move'
          @area = world.area command.destination
          @status = "You walk #{ command.direction }"
          console.dir @area
          player.position = command.destination
        when 'inspect'
          
        else throw new Error 'Unknown command type'

