require('chai').should()

magical = require '../src'

describe "ag-magic-model", ->
  it "is a function", ->
    magical.should.be.a 'function'

  it 'accepts a class and returns a magic-enhanced one', ->
    magical(class Foo).should.have.property('magical')

  describe 'a magical class', ->
    describe 'magical', ->
      it 'is an object', ->
        magical(class Foo).magical.should.be.an 'object'

  describe 'a magical instance', ->
    describe 'magical', ->
      it 'is an object', ->
        MagicalFoo = magical(class Foo)
        (new MagicalFoo).should.have.property('magical').be.an 'object'
