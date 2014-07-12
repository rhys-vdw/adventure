angular.module 'adventure-services', []

  .factory 'map', (Position) ->
    model =
      '[0,0]':
        description: 'A perfectly featureless room. There is a door to the north.'
        spawnItems: ['chair']
        exits: 'n'
      '[0,1]':
        description: 'A corridor'

    return {
      area: (x, y) ->
        position = new Position x, y
        return model[position.toString()]
    }

  .factory 'itemFactory', () ->
    model =
      'chair':
        name: 'chair'
        description: 'A chair for sitting'
        fixed: true

    return {
      spawn: (item) -> _.clone model[item]
    }

  .factory 'world', (map, itemFactory, Position) ->
    model = {}

    initialize = (position) ->
      areaConfig = _.clone map.area position
      if areaConfig
        key = position.toString()
        area = _.pick areaConfig, 'description', 'exits'
        area.items = _.map areaConfig.spawnItems, itemFactory.spawn
        model[key] = area

    return {
      area: (x, y) ->
        position = new Position x, y
        key = position.toString()
        area = model[key] or initialize position
        return area
    }

  .service 'Position', ->
    class Position
      constructor: (x, y) ->
        return x if x instanceof Position
        @x = x
        @y = y

      north: -> new Position @x    , @y + 1
      south: -> new Position @x    , @y - 1
      east:  -> new Position @x + 1, @y
      west:  -> new Position @x - 1, @y
      toString: -> "[#{@x},#{@y}]"

  .factory 'player', (Position) ->
    position: new Position 0, 0

  .service 'processInput', (player) ->
    (input) ->
      tokens = input.trim().toLowerCase().split /\s/
      command = switch tokens[0]
        when 'n', 'north'
          type: 'move'
          direction: 'north'
          destination: player.position.north()
        when 's', 'south'
          type: 'move'
          direction: 'south'
          destination: player.position.south()
        when 'e', 'east'
          type: 'move'
          direction: 'east'
          destination: player.position.east()
        when 'w', 'west'
          type: 'move'
          direction: 'west'
          destination: player.position.west()
        else
          undefined

      return command if command?

      if _.contains ['look', 'inspect'], tokens[0]
        command =
          type: 'inspect'
          object: _.last _.tail tokens
      else
        command =
          error: true
          message: "Did not understand '#{ input }'"

      return command
