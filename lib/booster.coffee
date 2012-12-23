Booster = ->
  instances = {}
  singletons = {}
  constructors = {}
  cache = {}

  start = (dependencies, fn) ->
    args = []

    for dependency in dependencies
      if singletons[dependency]
        unless cache.hasOwnProperty(dependency)
          cache[dependency] = process([], singletons[dependency].dependencies, singletons[dependency].fn)
        args.push(cache[dependency])
      else if constructors[dependency]
        args.push(constructors[dependency].fn)
      else
        if instances[dependency]
          throw new Error("Instances (#{dependency}) cannot be injected to start.")
        else
          throw new Error("Cannot find dependency #{dependency}")

    fn.apply(null, args)

  process = (argv, dependencies, fn) ->
    rest = Array.prototype.slice.call(dependencies, argv.length)
    args = Array.prototype.slice.call(argv, 0)
  
    for arg in rest
      if constructors[arg] and arg.slice(0, 1).match(/^[A-Z]$/)
        args.push constructors[arg].fn
      else
        if singletons[arg]
          unless cache.hasOwnProperty(arg)
            cache[arg] = process([], singletons[arg].dependencies, singletons[arg].fn)
          args.push cache[arg]
        else if instances[arg]
          args.push process(Array.prototype.slice.call(argv, 0), instances[arg].dependencies, instances[arg].fn)
        else
          throw new Error("Cannot find dependency #{arg}")

    fn.apply(null, args)

  service = (name, dependencies, fn) ->
    unless name.match(/^\$?[a-z][A-Za-z]*$/)
      throw new Error("Invalid name of service: #{name}")

    if name.slice(0, 1) is '$'
      constructorName = name.slice(1, 2).toUpperCase() + name.slice(2)
    else
      constructorName = name.slice(0, 1).toUpperCase() + name.slice(1)
  
    instances[name] =
      dependencies: dependencies
      fn: fn

    constructors[constructorName] =
      dependencies: dependencies
      fn:
        new: ->
          process(Array.prototype.slice.call(arguments, 0), dependencies, fn)

  factory = (name, dependencies, fn) ->
    unless name.match(/^[a-z][A-Za-z]*$/)
      throw new Error("Invalid name of factory: #{name}")

    for dependency in dependencies
      if instances[dependency]
        throw new Error("Instances (#{dependency}) cannot be injected to #factory.")

    singletons[name] =
      dependencies: dependencies
      fn: fn

  start: start
  service: service
  factory: factory

exports.Booster = Booster if exports?
