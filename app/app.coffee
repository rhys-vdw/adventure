angular.module 'adventure', [ 'ngRoute','adventure-main','templates' ]
  
  .config ($routeProvider) ->

    $routeProvider
      .otherwise
        redirectTo: '/'