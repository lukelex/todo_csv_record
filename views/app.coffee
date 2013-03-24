todo = angular.module 'todo', ['ngResource']

todo.directive "todoBlur", ->
  (scope, elem, attrs) ->
    elem.bind "blur", ->
      scope.$apply attrs.todoBlur

todo.directive "todoFocus", todoFocus = ($timeout) ->
  (scope, elem, attrs) ->
    scope.$watch attrs.todoFocus, (newVal) ->
      if newVal
        $timeout (->
          elem[0].focus()
        ), 0, false

todo.factory 'TodoStorage', ($resource) ->
  $resource '/todos/:todoId', {todoId:'@id', title: '@title', completed: '@completed'},{
    'removeCompleted': {method: 'DELETE'}
  }

todo.controller "TodoCtrl", ($scope, $location, TodoStorage, filterFilter) ->
  todos = null
  TodoStorage.query (data) ->
    for todo in data
      todo.completed = todo.completed is 'true'
    todos = $scope.todos = data

  $scope.newTodo = ""
  $scope.editedTodo = null

  $scope.$watch "todos", ->
    if todos
      $scope.remainingCount = filterFilter(todos,
        completed: false
      ).length
      $scope.completedCount = todos.length - $scope.remainingCount
      $scope.allChecked = not $scope.remainingCount
  , true

  $location.path "/"  if $location.path() is ""

  $scope.location = $location

  $scope.$watch "location.path()", (path) ->
    $scope.statusFilter = (if (path is "/active") then completed: false else (if (path is "/completed") then completed: true else null))

  $scope.addTodo = ->
    return unless $scope.newTodo.length

    todo = new TodoStorage
      title: $scope.newTodo
      completed: false
    todos.push todo
    todo.$save()

    $scope.newTodo = ""

  $scope.editTodo = (todo) ->
    $scope.editedTodo = todo

  $scope.doneEditing = (todo) ->
    $scope.editedTodo = null
    if todo.title
      todo.$save()
    else
      $scope.removeTodo todo

  $scope.completeTodo = (todo) ->
    $scope.doneEditing(todo)

  $scope.removeTodo = (todo) ->
    todos.splice todos.indexOf(todo), 1
    todo.$delete()

  $scope.clearCompletedTodos = ->
    $scope.todos = todos = todos.filter((val) ->
      not val.completed
    )
    TodoStorage.removeCompleted()

  $scope.markAll = (completed) ->
    todos.forEach (todo) ->
      todo.completed = completed

