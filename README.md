# Booster

JavaScript dependency injection library, inspired from Angular.js

## Usage

    Booster.service 'addition', ->
      (a, b) -> a + b

    Booster.service 'subtraction', ->
      (a, b) -> a - b
  
    Booster.service 'math', ['addition', 'subtraction'], (addition, subtraction) ->
      (a, b) -> addition a, (subtraction a, b)

    Booster.factory 'random', ->
      -> Math.round(Math.random() * 100)
      
    Booster.start ['math', 'random'], (math, random) ->
      console.log math(random(), random())
