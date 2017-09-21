#! /usr/bin/env node
'use strict'

const globby = require('globby')
const async = require('async')

const runner = require('./lib/runner')

require('./lib/cssstyle')

const argv =
  require('yargs')
    .usage('$0 [glob pattern or file:testID] -f format')
    .option('format', {
      alias: 'f',
      describe: 'Reporting format',
      choices: ['documentation', 'progress'],
      default: 'documentation'
    })
    .help('help')
    .argv

var glob
var id

if (argv._.length) {
  var file = argv._[0]
  var parts = file.split(':')
  glob = parts[0]
  id = parts[1]
} else {
  glob = ['spec/**/*Spec.elm']
}

globby(glob).then(paths => {
  var Reporter = require(`./lib/${argv.f}-reporter`)
  var reporter = new Reporter()

  async.eachSeries(paths,
    (path, callback) => {
      runner(path, id)((results) => {
        reporter.reportFile(results)
        callback()
      })
    }, (errors, allresults) => {
      reporter.reportResults()

      process.exit(reporter.exitCode)
    })
})
