Booster = ->
  definitions = {}
  cache = {}

  process = (dependencies, target) ->
    args = []

    for dependency in dependencies
      definition = definitions[dependency]
      if definition
        if definition.cache
          result = cache[definition] ?= process(definition.dependencies, definition.fn)
        else
          result = process(definition.dependencies, definition.fn)

        args.push result
  
    target.apply(target, args)

  define = (name, dependencies, fn, options = {}) ->
    if definitions[name]
      throw "Already defined factory or service '#{name}'"

    unless fn
      fn = dependencies
      dependencies = []

    options.fn = fn
    options.dependencies = dependencies

    definitions[name] = options

  factory = (name, dependencies, fn) ->
    define name, dependencies, fn, cache: true

  service = (name, dependencies, fn) ->
    define name, dependencies, fn, cache: false

  start = (dependencies, fn) ->
    unless fn
      fn = dependencies
      dependencies = []

    process(dependencies, fn)

  start: start
  factory: factory
  service: service

exports.Booster = Booster if exports?
