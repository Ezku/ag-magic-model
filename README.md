ag-magic-model
========

[![Build Status](http://img.shields.io/travis/AppGyver/ag-magic-model/master.svg)](https://travis-ci.org/AppGyver/ag-magic-model)
[![NPM version](http://img.shields.io/npm/v/ag-magic-model.svg)](https://www.npmjs.org/package/ag-magic-model)
[![Dependency Status](http://img.shields.io/david/AppGyver/ag-magic-model.svg)](https://david-dm.org/AppGyver/ag-magic-model)
[![Coverage Status](https://img.shields.io/coveralls/AppGyver/ag-magic-model.svg)](https://coveralls.io/r/AppGyver/ag-magic-model)

ag magic model npm library

## Continuous integration setup

### Code coverage reports

The project is set up with a test runner that is compatible with the [Coveralls](http://coveralls.io/) reporting tool. Travis will push the reports to Coveralls for you, if you provide it with the repository specific private token.

    travis encrypt COVERALLS_REPO_TOKEN=<your token here> --add

You might find that the `grunt travis` task doesn't pass without this token being set as an env variable. If you're using Travis without code coverage reporting, remove the relevant `mochacov` task configuration segment.
