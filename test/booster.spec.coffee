chai = require('chai')
chai.should()
fail = chai.assert.fail

describe 'Booster', ->
  beforeEach ->
    @Booster = require('../lib/booster').Booster()

  describe 'singleton', ->
    it 'should raise when name is incorrect', ->
      (=>
        @Booster.factory 'Math', ->
      ).should.throw('Invalid name of factory: Math')

    it 'should accept names with $ in front', (done) ->
      @Booster.factory '$math', [], done
      @Booster.start ['$math'], ($math) ->

    it 'should evalulate only once', ->
      calls = 0

      @Booster.factory 'once', [], ->
        if calls++ > 0
          fail('evaluated more than once')

      @Booster.start ['once'], (once) ->
      @Booster.start ['once'], (once) ->

    it 'should evalulate only once when deep', ->
      calls = 0

      @Booster.factory 'deep', [], ->
        if calls++ > 0
          fail('evaluated more than once')

      @Booster.service 'once', ['deep'], (deep) ->

      @Booster.start ['Once'], (Once) ->
        Once.new()
      @Booster.start ['Once'], (Once) ->
        Once.new()

    it 'should not inherit scope', (done) ->
      @Booster.factory 'deep', [], ->
        arguments.length.should.equal(0)
        done()

      @Booster.service 'once', ['arg', 'deep'], (arg, deep) ->

      @Booster.start ['Once'], (Once) ->
        Once.new('ARG')

  describe 'instance', ->
    it 'should raise when name is incorrect', ->
      (=>
        @Booster.service 'Math', ->
      ).should.throw('Invalid name of service: Math')

    it 'should automatically define a constructor', ->
      @Booster.service 'math', [], ->
        addition: (a, b) ->
          a + b

      @Booster.start ['Math'], (Math) ->
        math = Math.new()
        math.addition(1, 2).should.equal(3)

    it 'should support simple dependency injection', ->
      @Booster.service 'addition', [], ->
        (a, b) -> a + b

      @Booster.service 'math', ['addition'], (addition) ->
        addition: addition

      @Booster.start ['Math'], (Math) ->
        math = Math.new()
        math.addition(1, 2).should.equal(3)

    it 'should accept names with $ in front', (done) ->
      @Booster.factory '$window', [], ->
        done()

      @Booster.start ['$window'], ($window) ->
  
  describe 'middleware', ->
    it 'should not start when middleware does not call next', ->
      @Booster.middleware [], ->
      @Booster.start [], fail

    it 'should start when middleware calls next', (done) ->
      @Booster.middleware ['next'], (next) ->
        next()
      @Booster.start [], done

    it 'should start when middlewares calls next', (done) ->
      @Booster.middleware ['next'], (next) ->
        next()
      @Booster.middleware ['next'], (next) ->
        next()
      @Booster.start [], done

    it 'should be possible to wrap #next', (done) ->
      @Booster.middleware ['next'], (next) ->
        try
          next()
        catch error
          done()
      @Booster.factory 'one', [], ->
        throw new Error 'error'
      @Booster.start ['one'], (one) ->
        
  describe 'injection', ->
    describe '#start', ->
      it 'should be allowed to inject factories', (done) ->
        @Booster.factory 'one', [], ->
          done()
        @Booster.start ['one'], (one) ->

      it 'should be allowed to inject instances', (done) ->
        @Booster.service 'one', [], ->
          done()
        @Booster.start ['one'], (one) ->

      it 'should be allowed to inject constructors', (done) ->
        @Booster.service 'one', [], ->
          done()
        @Booster.start ['One'], (One) ->
          One.new()

      it 'should raise when singleton dependency does not exist', ->
        (=>
          @Booster.start ['one'], (one) ->
        ).should.throw('Missing dependency `one` in #start')

      it 'should raise when constructor dependency does not exist', ->
        (=>
          @Booster.start ['One'], (One) ->
        ).should.throw('Missing dependency `One` in #start')

    describe '#factory', ->
      it 'should be allowed to inject factories', (done) ->
        @Booster.factory 'two', [], ->
          done()
        @Booster.factory 'one', ['two'], (two) ->
        @Booster.start ['one'], (one) ->

      it 'should be allowed to inject instances', ->
        @Booster.service 'two', [], ->
        @Booster.factory 'one', ['two'], (two) ->
        @Booster.start ['one'], (one) ->

      it 'should be allowed to inject constructors', (done) ->
        @Booster.service 'two', [], ->
          done()
        @Booster.factory 'one', ['Two'], (Two) ->
          Two.new()
        @Booster.start ['one'], (one) ->

      it 'should raise when singleton/instance dependency does not exist', ->
        (=>
          @Booster.factory 'one', ['two'], (two) ->
          @Booster.start ['one'], (one) ->
        ).should.throw('Missing dependency `two` in #one')

      it 'should raise when constructor dependency does not exist', ->
        (=>
          @Booster.factory 'one', ['Two'], (Two) ->
          @Booster.start ['one'], (one) ->
        ).should.throw('Missing dependency `Two` in #one')

    describe '#service', ->
      it 'should be allowed to inject factories', (done) ->
        @Booster.factory 'two', [], ->
          done()
        @Booster.service 'one', ['two'], (two) ->
        @Booster.start ['One'], (One) ->
          One.new()

      it 'should be allowed to inject instances', (done) ->
        @Booster.service 'two', [], ->
          done()
        @Booster.service 'one', ['two'], (two) ->
        @Booster.start ['One'], (One) ->
          One.new()

      it 'should be allowed to inject constructors', (done) ->
        @Booster.service 'two', [], ->
          done()
        @Booster.service 'one', ['Two'], (Two) ->
          Two.new()
        @Booster.start ['One'], (One) ->
          One.new()

      it 'should raise when singleton/instance dependency does not exist', ->
        (=>
          @Booster.service 'one', ['two'], (two) ->
          @Booster.start ['One'], (One) ->
            One.new()
        ).should.throw('Missing dependency `two` in #one')

      it 'should raise when constructor dependency does not exist', ->
        (=>
          @Booster.service 'one', ['Two'], (Two) ->
          @Booster.start ['One'], (One) ->
            One.new()
        ).should.throw('Missing dependency `Two` in #one')

    describe '#middleware', ->
      it 'should be allowed to inject factories', (done) ->
        @Booster.factory 'one', [], ->
          done()
        @Booster.middleware ['next', 'one'], (next, one) ->
          next()
        @Booster.start [], ->

      it 'should not be allowed to inject instances', ->
        (=>
          @Booster.service 'one', [], ->
          @Booster.middleware ['next', 'one'], (next, one) ->
            next()
          @Booster.start [], ->
        ).should.throw('Instances (one) cannot be injected to #middleware.')

      it 'should be allowed to inject constructors', (done) ->
        @Booster.service 'one', [], ->
          done()
        @Booster.middleware ['next', 'One'], (next, One) ->
          One.new()
        @Booster.start [], ->
  
      it 'should raise when singleton dependency does not exist', ->
        (=>
          @Booster.middleware ['next', 'one'], (next, one) ->
          @Booster.start [], ->
        ).should.throw('Missing dependency `one` in #middleware')

      it 'should raise when constructor dependency does not exist', ->
        (=>
          @Booster.middleware ['next', 'One'], (next, One) ->
          @Booster.start [], ->
        ).should.throw('Missing dependency `One` in #middleware')