#! /usr/bin/env node
"use strict"

const globby = require('globby')
const async = require('async')

const runner = require('./lib/runner')

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

if(argv._.length){
  var file = argv._[0]
  var parts = file.split(':')
  glob = parts[0]
  id = parts[1]
} else {
  glob = ['spec/**Spec.elm']
}

globby(glob).then(paths => {
  var Reporter = require(`./lib/${argv.f}-reporter`)

  var files = paths.map(path => { return runner(path, id) })

  async.series(files, function(errors, allresults){
    var reporter = new Reporter(allresults)
    reporter.report()

    process.exit(reporter.exitCode)
  })
});
