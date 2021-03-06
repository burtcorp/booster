# Booster

JavaScript dependency injection library, inspired by Angular.js

## Why?

Dependency injection is awesome because it allows you to test your
code. Booster is awesome because it helps you do dependency injection
in a simple and clean way.

## How?

In booster there are three different object concepts: `singleton`,
`constructor` and `instance`. These objects all live in a scope. A
scope is created like this:

    Scope = Booster()

### Singleton

A singleton is an object that is created once and then cached
forever and it has no constructor.

To define a singleton, use the `#factory` function.

    Scope.factory 'config', [], ->
      min: 0
      max: 100
      log: false

Usage:

    Scope.start ['config'], (config) ->
      console.log config.min # 0
      console.log config.max # 100
      console.log config.log # false

### Instance

When you create an instance, Booster automatically creates a
constructor for you. All instances that are injected to that
definition, inherits the objects this object was created
with. Inheritence can be avoided by instead injecting the
constructor. Example:

    Scope.service 'domNode', ['node'], (node) ->
      width: -> node.clientWidth
      height: -> node.clientHeight
      getAttribute: node.getAttribute
     
    Scope.service 'image', ['node', 'domNode'], (node, domNode) ->
      width: domNode.width
      height: domNode.height
      alt: -> domNode.getAttribute('alt')
     
    Scope.service 'window', ['$window', 'Image'], ($window, Image) ->
      images = []
     
      for node in $window.document.getElementsByTagName('IMG')
        images.push Image.new(node)
      
      images: images
     
    Scope.start ['Window'], (Window) ->
      $window = Window.new(window)
     
      for image in $window.images
        console.log image.height()
        console.log image.width()
        console.log image.alt()
        
### Middleware

A middleware is a filter between start and the definitions. Here's an
example where the application throws errors only if hostname is
localhost. Otherwise all errors are pushed to an API.

    Scope.middleware ['next', 'api'], (next, api) ->
      if window.location.hostname is 'localhost'
        next()
      else
        try
          next()
        catch error
          api.push error.toString()
        
    Scope.start [], ->
      # Will push to api in production and throw error in development.
      throw new Error('ALARM')

## Example

See <https://github.com/burtcorp/booster/blob/master/test/booster.spec.coffee>
