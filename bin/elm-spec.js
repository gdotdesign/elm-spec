#! /usr/bin/env node

var LocalStorage = require('node-localstorage').LocalStorage
var which = require('npm-which')(__dirname)
var spawn = require('child_process').spawn
var temp = require('temp').track()
var globby = require('globby')
var colors = require('colors')
var jsdom = require('jsdom')
var async = require('async')
var fs = require('fs')

var Reporter = require('./lib/progress-reporter.js')

var elmExecutable = which.sync('elm-make')

var render = function(file, callback) {
  var filename = temp.openSync({ suffix: '.js' }).path

  var arguments =
    [file, '--output', filename, '--yes']

  var result = ''
  var command

  command = spawn(elmExecutable, arguments)

  command.stdout.on('data', (data) => {
    result += data
  })

  command.stderr.on('data', (data) => {
    result += data
  })

  command.on('close', function() {
    if (result.match('Successfully generated')) {
      callback(null, filename)
    } else {
      callback(result, filename)
    }
  })
}

var sessionStorage = new LocalStorage(temp.mkdirSync());
var localStorage = new LocalStorage(temp.mkdirSync());

var run = function(file, testId) {
  return function(callback){
    render(file, function(result, filename){
      if(result){
        console.log(result)
        callback(null, [])
      } else {
        var testIdFileContents = "window._elmSpecTestId = " + testId + ";"
        var testIdFile = temp.openSync({ suffix: '.js' }).path
        fs.writeFileSync(testIdFile, testIdFileContents)

        jsdom.env({
          virtualConsole: jsdom.createVirtualConsole().sendTo(console),
          cookieJar: jsdom.createCookieJar(),
          url: "http://localhost:8080/",
          scripts: [
            "file:///" + __dirname + "/lib/raf.js",
            "file:///" + testIdFile,
            "file:///" + filename
          ],
          html: `
            <html>
              <head>
                <base href='http://localhost:8080/'></base>
                <title>Elm-Spec</title>
              </head>
            </html>`,
          done: function (err, window) {
            window.sessionStorage = sessionStorage
            window.localStorage = localStorage
            sessionStorage.clear()
            localStorage.clear()

            if(!window.Elm){
              console.log(`No Main found for: ${file}, skipping...`)
            } else {
              var app = window.Elm.Main.embed(window.document.body)
              window._elmSpecReport = function(results){
                callback(null, { file: file, tests: results })
              }
            }
          }
        })
      }
    })
  }
}

var args = process.argv.slice(2)
var glob
var id

if(args.length){
  var file = args[0]
  var parts = file.split(':')
  glob = parts[0]
  id = parts[1]
} else {
  glob = ['spec/**Spec.elm']
}

globby(glob).then(paths => {
  var files = paths.map(path => { return run(path, id) })
  async.series(files, function(errors, allresults){
    var reporter = new Reporter(allresults)
    reporter.report()

    process.exit(reporter.exitCode)
  })
});
