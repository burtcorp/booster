Booster = ->
  factories = {}

  process = (dependencies, target) ->
    args = []

    for dependency in dependencies
      factory = factories[dependency]

      if factory.dependencies
        factory.cache ?= process(factory.dependencies, factory.fn)

        args.push factory.cache

    target.apply(target, args)

  factory = (name, dependencies, fn) ->
    if factories[name]
      throw "Factory '#{name}' already defined"

    unless fn
      fn = dependencies
      dependencies = []

    factories[name] =
      fn: fn
      dependencies: dependencies

  start = (dependencies, fn) ->
    unless fn
      fn = dependencies
      dependencies = []

    process(dependencies, fn)

  start: start
  factory: factory

exports.Booster = Booster if exports?
