Booster = ->
  instances = {}
  singletons = {}
  constructors = {}
  middlewares = []
  cache = {}

  ready = do ->
    callback = undefined

    (fn) ->
      if fn
        callback = fn
      else
        callback()

  start = (dependencies, fn) ->
    ready ->
      args = []

      for dependency in dependencies
        if singleton = singletons[dependency]
          unless cache.hasOwnProperty(dependency)
            cache[dependency] = process([], singleton.dependencies, singleton.fn, singleton.name)
          args.push(cache[dependency])
        else if constructor = constructors[dependency]
          args.push(constructor.fn)
        else if instance = instances[dependency]
          args.push process([], instance.dependencies, instance.fn, instance.name)
        else
          throw new Error("Missing dependency `#{dependency}` in #start")

      fn.apply(null, args)

    if middlewares.length > 0
      middlewares[middlewares.length - 1]()
    else
      ready()

  process = (argv, dependencies, fn, name = null) ->
    args = Array.prototype.slice.call(argv, 0)
    rest = Array.prototype.slice.call(dependencies, argv.length)

    for arg in rest
      if constructors[arg] and arg.slice(0, 1).match(/^[A-Z]$/)
        args.push constructors[arg].fn
      else
        if singleton = singletons[arg]
          unless cache.hasOwnProperty(arg)
            cache[arg] = process([], singleton.dependencies, singleton.fn, singleton.name)
          args.push cache[arg]
        else if instance = instances[arg]
          args.push process([], instance.dependencies, instance.fn, instance.name)
        else
          throw new Error("Missing dependency `#{arg}` in ##{name}")

    fn.apply(null, args)

  service = (name, dependencies, fn) ->
    unless name.match(/^\$?[a-z][A-Za-z]*$/)
      throw new Error("Invalid name of service: #{name}")

    if name.slice(0, 1) is '$'
      constructorName = name.slice(1, 2).toUpperCase() + name.slice(2)
    else
      constructorName = name.slice(0, 1).toUpperCase() + name.slice(1)
  
    instances[name] =
      name: name
      dependencies: dependencies
      fn: fn

    constructors[constructorName] =
      name: constructorName
      dependencies: dependencies
      fn:
        new: ->
          process(Array.prototype.slice.call(arguments, 0), dependencies, fn, name)

  factory = (name, dependencies, fn) ->
    unless name.match(/^\$?[a-z][A-Za-z]*$/)
      throw new Error("Invalid name of factory: #{name}")

    for dependency in dependencies
      if instances[dependency]
        throw new Error("Instances (#{dependency}) cannot be injected to #factory.")

    singletons[name] =
      name: name
      dependencies: dependencies
      fn: fn

  middleware = (dependencies, fn) ->
    unless middlewares.length > 0
      middlewares.push(ready)

    prev = middlewares[middlewares.length - 1]

    for dependency in dependencies[1..]
      if instances[dependency]
        throw new Error("Instances (#{dependency}) cannot be injected to #middleware.")

    middlewares.push ->
      process [prev], dependencies, fn, 'middleware'

  start: start
  service: service
  factory: factory
  middleware: middleware

exports.Booster = Booster if exports?
