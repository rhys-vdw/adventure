angular.module 'adventure-services', []

  .factory 'map', (Position) ->
    model =
      '[0,0]':
        description: 'A perfectly featureless room. There is a door to the north.'
        spawnItems: ['chair', 'arden']
        exits: 'n'
      '[0,1]':
        description: 'A corridor. There is a door at the south end leading back to the room.'
        exits: 's'

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
        actions: ['sit']
      'arden':
        name: 'Arden'
        description: 'A nerd'

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

  .factory 'words', () ->
    verbs = [
      ['sit', 'rest']
      ['inspect', 'look']
      ['move', 'push', 'slide']
      ['go', 'walk']
    ]

    prepositions = [
      ['to']
      ['from']
      ['with', 'at', 'on']
    ]

    directions = [
      ['north', 'n']
      ['south', 's']
      ['east', 'e']
      ['west', 'w']
    ]

    # Find the group that contains the given word, and return its first
    # element.
    check = (category, word) ->
      _.first(_(category)
        .find (group) -> _(group).contains word
      )

    return {
      identify: (word) ->
        if verb = check verbs, word
          return type: 'verb', word: verb

        if preposition = check prepositions, word
          return type: 'preposition', word: preposition

        if direction = check directions, word
          return type: 'direction', word: direction

        return type: 'other', word: word
    }

  .service 'processInput', (player, words) ->
    (input) ->
      rawTokens = input.trim().toLowerCase().split /\s/
      tokens = _.map rawTokens, words.identify

      verb = _(tokens).find(type: 'verb')?.word

      if ! verb? or verb == 'go'
        direction = _(tokens).find(type: 'direction')?.word
        if direction?
          return {
            type: 'move'
            direction: direction
            destination: player.position[direction]()
          }

      if verb == 'inspect'
        return {
          type: 'inspect'
          object: _(tokens).find(type: 'other')?.word
        }

      return {
        error: true
        message: "Did not understand '#{ input }'"
      }

      return command
