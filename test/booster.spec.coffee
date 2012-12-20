chai = require('chai')
chai.should()
fail = chai.assert.fail

describe 'Booster', ->
  beforeEach ->
    @Booster = require('../lib/booster').Booster()

  describe 'singleton', ->
    it 'should raise when name is incorrect', ->
      (->
        @Booster.factory 'Math', ->
      ).bind(@).should.throw()

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
      (->
        @Booster.service 'Math', ->
      ).bind(@).should.throw()

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

    it 'should support scope inheritence', ->
      @Booster.service 'addition', ['a', 'b'], (a, b) ->
        -> a + b

      @Booster.service 'subtraction', ['a', 'b'], (a, b) ->
        -> a - b

      @Booster.service 'math', ['a', 'b', 'addition', 'subtraction'], (a, b, addition, subtraction) ->
        addition: addition
        subtraction: subtraction

      @Booster.start ['Math'], (Math) ->
        math = Math.new(1, 2)
        math.addition().should.equal(3)
        math.subtraction().should.equal(-1)

    it 'should support scope inheritence with dependency injection', ->
      @Booster.service 'science', ['a', 'b'], (a, b) ->
        addition: -> a + b
        subtraction: -> a - b

      @Booster.service 'addition', ['a', 'b', 'science'], (a, b, science) ->
        science.addition

      @Booster.service 'subtraction', ['a', 'b', 'science'], (a, b, science) ->
        science.subtraction

      @Booster.service 'math', ['a', 'b', 'addition', 'subtraction'], (a, b, addition, subtraction) ->
        addition: addition
        subtraction: subtraction

      @Booster.start ['Math'], (Math) ->
        math = Math.new(1, 2)
        math.addition().should.equal(3)
        math.subtraction().should.equal(-1)

    it 'should accept names with $ in front', (done) ->
      win =
        rand: Math.random()

      count = 0

      test = ($window) ->
        win.should.eql($window)
        if ++count is 3
          done()

      @Booster.service 'pageObserver', ['$window'], ($window) ->
        test($window)

      @Booster.service 'page', ['$window'], ($window) ->
        test($window)

      @Booster.service 'pageTracker', ['$window', 'pageObserver', 'page'], ($window, pageObserver, page) ->
        test($window)

      @Booster.start ['PageTracker'], (PageTracker) ->
        PageTracker.new(win)

  describe 'injection', ->
    describe '#start', ->
      it 'should be allowed to inject factories', (done) ->
        @Booster.factory 'one', [], ->
          done()
        @Booster.start ['one'], (one) ->
  
      it 'should not be allowed to inject instances', ->
        (->
          @Booster.service 'one', [], ->
          @Booster.start ['one'], (one) ->
        ).bind(@).should.throw()
  
      it 'should be allowed to inject constructors', (done) ->
        @Booster.service 'one', [], ->
          done()
        @Booster.start ['One'], (One) ->
          One.new()
  
    describe '#factory', ->
      it 'should be allowed to inject factories', (done) ->
        @Booster.factory 'two', [], ->
          done()
        @Booster.factory 'one', ['two'], (two) ->
        @Booster.start ['one'], (one) ->

      it 'should not be allowed to inject instances', ->
        (->
          @Booster.service 'two', [], ->
          @Booster.factory 'one', ['two'], (two) ->
          @Booster.start ['one'], (one) ->
        ).bind(@).should.throw()
  
      it 'should not be allowed to inject constructors', ->
        (->
          @Booster.service 'two', [], ->
          @Booster.factory 'one', ['Two'], (Two) ->
          @Booster.start (one) ->
        ).bind(@).should.throw()

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