angular.module("templates", []).run(["$templateCache", function($templateCache) {$templateCache.put("main/main.html","<div ng-bind=\"ctrl.area.description\" class=\"description\"></div><div ng-show=\"ctrl.area.items.length &gt; 0\" class=\"area-items\"><p>There are some things here:</p><ul><li ng-repeat=\"item in ctrl.area.items\">{{ item.name }}</li></ul></div><div ng-bind=\"ctrl.status\" class=\"status\"></div><form ng-submit=\"ctrl.userAction(inputText)\"><input type=\"text\" ng-model=\"inputText\"/><div ng-bind=\"ctrl.error\"></div></form>");}]);