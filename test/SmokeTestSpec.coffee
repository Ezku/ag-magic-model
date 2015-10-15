require('chai').should()

describe "ag-magic-model root", ->
  it "should be defined", ->
    require('../src').should.exist