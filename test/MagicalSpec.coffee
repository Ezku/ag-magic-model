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

      describe 'definition', ->
        it 'is an object', ->
          magical('foo').magical.should.have.property('definition').be.an 'object'

      describe 'label', ->
        it 'is an object', ->
          magical('foo').magical.should.have.property('label').be.an 'object'

      describe 'formatter', ->
        it 'is an object', ->
          magical('foo').magical.should.have.property('formatter').be.an 'object'

      describe 'titles', ->
        it 'is an object', ->
          magical('foo').magical.should.have.property('titles').be.an 'object'

        describe 'plural', ->
          it 'is a string', ->
            magical('foo').magical.titles.should.have.property('plural').be.a 'string'

        describe 'singular', ->
          it 'is a string', ->
            magical('foo').magical.titles.should.have.property('singular').be.a 'string'

        describe 'record', ->
          it 'is a function', ->
            magical('foo').magical.titles.should.have.property('record').be.a 'function'

      describe 'routes', ->
        it 'is an object', ->
          magical('foo').magical.should.have.property('routes').be.an 'object'

        describe 'new', ->
          it 'is a string', ->
            magical('foo').magical.routes.should.have.property('new').be.a 'string'

      describe 'relations', ->
        it 'is an object', ->
          magical('foo').magical.should.have.property('relations').be.an 'object'

        describe 'join', ->
          it 'is a function', ->
            magical('foo').magical.relations.should.have.property('join').be.a 'function'

