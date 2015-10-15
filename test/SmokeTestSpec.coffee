require('chai').should()

magical = require '../src'

describe "ag-magic-model", ->
  it "is a function", ->
    magical.should.be.a 'function'
