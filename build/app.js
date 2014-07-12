angular.module('adventure', ['ngRoute', 'adventure-main', 'templates']).config(function($routeProvider) {
  return $routeProvider.otherwise({
    redirectTo: '/'
  });
});

'app controller goes here';


angular.module('adventure-services', []).factory('map', function(Position) {
  var model;
  model = {
    '[0,0]': {
      description: 'A perfectly featureless room. There is a door to the north.',
      spawnItems: ['chair'],
      exits: 'n'
    },
    '[0,1]': {
      description: 'A corridor'
    }
  };
  return {
    area: function(x, y) {
      var position;
      position = new Position(x, y);
      return model[position.toString()];
    }
  };
}).factory('itemFactory', function() {
  var model;
  model = {
    'chair': {
      name: 'chair',
      description: 'A chair for sitting',
      fixed: true
    }
  };
  return {
    spawn: function(item) {
      return _.clone(model[item]);
    }
  };
}).factory('world', function(map, itemFactory, Position) {
  var initialize, model;
  model = {};
  initialize = function(position) {
    var area, areaConfig, key;
    areaConfig = _.clone(map.area(position));
    if (areaConfig) {
      key = position.toString();
      area = _.pick(areaConfig, 'description', 'exits');
      area.items = _.map(areaConfig.spawnItems, itemFactory.spawn);
      return model[key] = area;
    }
  };
  return {
    area: function(x, y) {
      var area, key, position;
      position = new Position(x, y);
      key = position.toString();
      area = model[key] || initialize(position);
      return area;
    }
  };
}).service('Position', function() {
  var Position;
  return Position = (function() {
    function Position(x, y) {
      if (x instanceof Position) {
        return x;
      }
      this.x = x;
      this.y = y;
    }

    Position.prototype.north = function() {
      return new Position(this.x, this.y + 1);
    };

    Position.prototype.south = function() {
      return new Position(this.x, this.y - 1);
    };

    Position.prototype.east = function() {
      return new Position(this.x + 1, this.y);
    };

    Position.prototype.west = function() {
      return new Position(this.x - 1, this.y);
    };

    Position.prototype.toString = function() {
      return "[" + this.x + "," + this.y + "]";
    };

    return Position;

  })();
}).factory('player', function(Position) {
  return {
    position: new Position(0, 0)
  };
}).service('processInput', function(player) {
  return function(input) {
    var command, tokens;
    tokens = input.trim().toLowerCase().split(/\s/);
    command = (function() {
      switch (tokens[0]) {
        case 'n':
        case 'north':
          return {
            type: 'move',
            direction: 'north',
            destination: player.position.north()
          };
        case 's':
        case 'south':
          return {
            type: 'move',
            direction: 'south',
            destination: player.position.south()
          };
        case 'e':
        case 'east':
          return {
            type: 'move',
            direction: 'east',
            destination: player.position.east()
          };
        case 'w':
        case 'west':
          return {
            type: 'move',
            direction: 'west',
            destination: player.position.west()
          };
        default:
          return void 0;
      }
    })();
    if (command != null) {
      return command;
    }
    if (_.contains(['look', 'inspect'], tokens[0])) {
      command = {
        type: 'inspect',
        object: _.last(_.tail(tokens))
      };
    } else {
      command = {
        error: true,
        message: "Did not understand '" + input + "'"
      };
    }
    return command;
  };
});

angular.module('adventure-main', ['ngRoute', 'adventure-services']).config(function($routeProvider) {
  return $routeProvider.when('/', {
    templateUrl: 'main/main.html',
    controller: 'MainCtrl as ctrl'
  });
}).controller('MainCtrl', function(processInput, player, world) {
  return {
    area: world.area(player.position),
    userAction: function(inputText) {
      var command, object;
      command = processInput(inputText);
      if (command.error) {
        this.error = command.message;
        return;
      }
      this.error = '';
      switch (command.type) {
        case 'move':
          this.area = world.area(command.destination);
          this.status = "You walk " + command.direction;
          console.dir(this.area);
          return player.position = command.destination;
        case 'inspect':
          if (command.object != null) {
            object = _.find(this.area.items, {
              name: command.object
            });
            return this.status = (object != null ? object.description : void 0) || ("Can't see " + command.object);
          } else {
            return this.status = 'Inspect what?';
          }
          break;
        default:
          throw new Error('Unknown command type');
      }
    }
  };
});
