Booster = ->
  services = {}
  factories = {}

  process = (dependencies, target) ->
    args = []

    for dependency in dependencies
      factory = factories[dependency]
      if factory and factory.dependencies
        factory.cache ?= process(factory.dependencies, factory.fn)
        args.push factory.cache
  
      service = services[dependency]
      if service and service.dependencies
        args.push process(service.dependencies, service.fn)

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
  
  service = (name, dependencies, fn) ->
    if services[name]
      throw "Service '#{name}' already defined"

    unless fn
      fn = dependencies
      dependencies = []

    services[name] =
      fn: fn
      dependencies: dependencies

  start = (dependencies, fn) ->
    unless fn
      fn = dependencies
      dependencies = []

    process(dependencies, fn)

  start: start
  factory: factory
  service: service

exports.Booster = Booster if exports?
