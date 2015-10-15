require('chai').should()

magical = require '../src'

describe "ag-magic-model", ->
  it "is a function", ->
    magical.should.be.a 'function'

  it 'accepts a model name and returns a magic-enhanced one', ->
    magical('foo').should.have.property('magical')

  describe 'a magical class', ->
    describe 'magical', ->
      it 'is an object', ->
        magical('foo').magical.should.be.an 'object'

      describe 'name', ->
        it 'is the model name', ->
          magical('foo').magical.should.have.property('name').equal 'foo'

      describe 'label', ->
        it 'is an object', ->
          magical('foo').magical.should.have.property('label').be.an 'object'

  describe 'a magical instance', ->
    describe 'magical', ->
      it 'is an object', ->
        MagicalFoo = magical('foo')
        (new MagicalFoo).should.have.property('magical').be.an 'object'

      describe 'formatted', ->
        it 'is an object', ->
          MagicalFoo = magical('foo')
          (new MagicalFoo).magical.should.have.property('formatted').be.an 'object'