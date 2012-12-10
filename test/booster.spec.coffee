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