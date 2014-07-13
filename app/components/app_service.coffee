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
      areaConfig: (x, y) ->
        position = new Position x, y
        return model[position.toString()]
    }

  .factory 'items', () ->
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
      names: -> _.map model, 'name'
    }

  .factory 'world', (map, items, Position) ->
    model = {}

    class Area
      constructor: (config) ->
        _.extend @, _.pick config, 'description', 'exits'
        @items = _.map config.spawnItems, items.spawn

      hasExit: (direction) ->
        _.contains @exits, _.first direction

    return {
      area: (x, y) ->

        # Get lookup key from position.
        position = new Position x, y
        key = position.toString()

        # Find area.
        area = model[key]

        # If it doesn't exist, create it.
        if ! area?
          config = map.areaConfig position
          area = model[key] = new Area config if config?

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

  .factory 'words', (items) ->
    verbs = [
      ['sit', 'rest']
      ['inspect', 'look']
      ['move', 'push', 'slide']
      ['go', 'walk']
    ]

    prepositions = [
      ['to']
      ['from']
      ['with', 'at', 'on', 'in']
    ]

    items = items.names()

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

        console.log "finding #{ word } in ", items
        if _.contains items, word
          console.log "got it!"
          return type: 'item', word: word

        return type: 'other', word: word
    }

  .service 'processInput', (player, words) ->
    (input) ->
      rawTokens = input.trim().toLowerCase().split /\s/
      tokens = _.map rawTokens, words.identify

      console.log "tokens", tokens

      verb = _(tokens).find(type: 'verb')?.word

      # Special case for movement.
      if ! verb? or verb == 'go'
        if direction = _(tokens).find(type: 'direction')?.word
          return {
            type: 'go'
            direction: direction
            destination: player.position[direction]()
          }

      # All other verbs assume an object.
      if verb?
        return {
          type: verb
          object: _(tokens).find(type: 'item')?.word
        }

      return {
        error: true
        message: "Did not understand '#{ input }'"
      }

      return command
