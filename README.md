ag-magic-model
========

[![Build Status](http://img.shields.io/travis/AppGyver/ag-magic-model/master.svg)](https://travis-ci.org/AppGyver/ag-magic-model)
[![NPM version](http://img.shields.io/npm/v/ag-magic-model.svg)](https://www.npmjs.org/package/ag-magic-model)
[![Dependency Status](http://img.shields.io/david/AppGyver/ag-magic-model.svg)](https://david-dm.org/AppGyver/ag-magic-model)
[![Coverage Status](https://img.shields.io/coveralls/AppGyver/ag-magic-model.svg)](https://coveralls.io/r/AppGyver/ag-magic-model)

ag magic model npm library

## Continuous integration setup

### Getting started

This project comes with a [Travis CI](https://travis-ci.org/) setup. All you need to do is enable Travis for your project through its web interface.

If you intend to set up continuous deployment or code coverage reports, the Travis command line client comes in useful. It's installed as a Ruby gem.

    gem install travis

### Continuous deployment

The project is configured for deployment to npm on successfully building, tagged commits. You'll only need to provide your npm api key for Travis to work its magic.

    cat ~/.npmrc | grep '_authToken\b' | sed 's/[^_]*_authToken=//' | travis encrypt --add deploy.api_key --no-interactive

This reads the key from your .npmrc file and saves it to the travis configuration.

### Code coverage reports

The project is set up with a test runner that is compatible with the [Coveralls](http://coveralls.io/) reporting tool. Travis will push the reports to Coveralls for you, if you provide it with the repository specific private token.

    travis encrypt COVERALLS_REPO_TOKEN=<your token here> --add

You might find that the `grunt travis` task doesn't pass without this token being set as an env variable. If you're using Travis without code coverage reporting, remove the relevant `mochacov` task configuration segment.
