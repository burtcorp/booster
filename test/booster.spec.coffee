should = require('should')

describe 'Booster', ->
  beforeEach ->
    @Booster = require('../lib/booster').Booster()

  describe '#factory', ->
    it 'should define simple factory', (done) ->
      @Booster.factory 'addition', ->
        (a, b) -> a + b

      @Booster.start ['addition'], (addition) ->
        (addition 1, 1).should.equal(2)
      @Booster.start(done)

    it 'should define nested factory', (done) ->
      @Booster.factory 'addition', ->
        (a, b) -> a + b
  
      @Booster.factory 'multiplication', ['addition'], (addition) ->
        (a, b) -> 
          sum = 0
          sum = (addition sum, a) for i in [1..b]
          sum
          
      @Booster.start ['multiplication'], (multiplication) ->
        (multiplication 2, 2).should.equal(4)
      @Booster.start(done)
  
    it 'should define factory with multiple arguments', (done) ->
      @Booster.factory 'addition', ->
        (a, b) -> a + b
      @Booster.factory 'subtraction', ->
        (a, b) -> a - b
      @Booster.factory 'math', ['addition', 'subtraction'], (addition, subtraction) ->
        (a, b) -> addition a, (subtraction a, b)
  
      @Booster.start ['math'], (math) ->
        math(1, 3).should.equal(-1)
      @Booster.start(done)

    it 'should be singleton', (done) ->
      @Booster.factory 'random', ->
        Math.random()
  
      value = undefined

      @Booster.start ['random'], (random) ->
        value = random
      @Booster.start ['random'], (random) ->
        value.should.equal(random)
      @Booster.start(done)

    it 'should raise error when factory already defined', ->
      @Booster.factory 'foo', ->
      
      (->
        @Booster.factory 'foo', ->
        ).bind(@).should.throw()
  
    it 'should raise error when dependency does not exist', (done) ->
      @Booster.factory 'foo', ['bar'], (bar) ->

      (->
        @Booster.start 'foo', ->
        ).bind(@).should.throw()
  
      @Booster.start(done)

  describe '#service', ->
    it 'should define simple service', (done) ->
      @Booster.service 'addition', ->
        (a, b) -> a + b

      @Booster.start ['addition'], (addition) ->
        (addition 1, 1).should.equal(2)
      @Booster.start(done)

    it 'should define nested service', (done) ->
      @Booster.service 'addition', ->
        (a, b) -> a + b
  
      @Booster.service 'multiplication', ['addition'], (addition) ->
        (a, b) -> 
          sum = 0
          sum = (addition sum, a) for i in [1..b]
          sum
          
      @Booster.start ['multiplication'], (multiplication) ->
        (multiplication 2, 2).should.equal(4)
      @Booster.start(done)
  
    it 'should define service with multiple arguments', (done) ->
      @Booster.service 'addition', ->
        (a, b) -> a + b
      @Booster.service 'subtraction', ->
        (a, b) -> a - b
      @Booster.service 'math', ['addition', 'subtraction'], (addition, subtraction) ->
        (a, b) -> addition a, (subtraction a, b)
  
      @Booster.start ['math'], (math) ->
        math(1, 3).should.equal(-1)
      @Booster.start(done)

    it 'should not be singleton', (done) ->
      @Booster.service 'random', ->
        Math.random()
  
      value = undefined

      @Booster.start ['random'], (random) ->
        value = random
      @Booster.start ['random'], (random) ->
        value.should.not.equal(random)
      @Booster.start(done)

    it 'should raise error when service already defined', ->
      @Booster.service 'foo', ->
      
      (->
        @Booster.service 'foo', ->
        ).bind(@).should.throw()

    it 'should raise error when dependency does not exist', (done) ->
      @Booster.service 'foo', ['bar'], (bar) ->

      (->
        @Booster.start 'foo', ->
        ).bind(@).should.throw()
  
      @Booster.start(done)
