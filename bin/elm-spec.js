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
      console.log(file)
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
                results.forEach(function(test){
                  test.path = file
                  console.log(" " + test.name.bold)
                  test.results.forEach(function(result){
                    switch(result.outcome) {
                      case "pass":
                        console.log("   " + result.message.green)
                        break
                      case "fail":
                        console.log("   " + result.message.red)
                        break
                      case "error":
                        console.log("   " + result.message.bgRed)
                    }
                  })

                  if(test.mockedRequests.length ||
                     test.notMockedRequests.length ||
                     test.unhandledRequests.length) {
                    console.log("   Requests:")
                    test.mockedRequests.forEach(function(req){
                      console.log(("     ✔ " + req.method + " - " + req.url).green)
                    })

                    test.notMockedRequests.forEach(function(req){
                      console.log(("     ✘ " + req.method + " - " + req.url).red)
                    })

                    test.unhandledRequests.forEach(function(req){
                      console.log(("     ? " + req.method + " - " + req.url).bgRed)
                    })
                  }

                  console.log("")
                })

                console.log("")
                callback(null, results)
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
    var results = allresults.reduce(function(memo, a) { return memo.concat(a) }, [])
    var steps = results.reduce(function(memo, test) {
      return memo + test.results.length
    }, 0)

    var failed = results.reduce(function(memo, test) {
      return memo +  test.results.filter(function(result){ return result.outcome == 'fail' }).length
    }, 0)

    var errored = results.reduce(function(memo, test) {
      return memo +  test.results.filter(function(result){ return result.outcome == 'error' }).length
    }, 0)

    var successfull = results.reduce(function(memo, test) {
      return memo + test.results.filter(function(result){ return result.outcome == 'pass' }).length
    }, 0)

    var requests = results.reduce(function(memo, test) {
      return memo + test.mockedRequests.length + test.notMockedRequests.length + test.unhandledRequests.length
    }, 0)

    var called = results.reduce(function(memo, test) {
      return memo + test.mockedRequests.length
    }, 0)

    var notcalled = results.reduce(function(memo, test) {
      return memo + test.notMockedRequests.length
    }, 0)

    var unhandled = results.reduce(function(memo, test) {
      return memo + test.unhandledRequests.length
    }, 0)

    var failedTest = results.filter(function(test){
      var failedSteps = test.results.filter(function(step){
        return step.outcome === 'fail' || step.outcome === 'error'
      }).length

      return failedSteps > 0 || test.notMockedRequests.length > 0 || test.unhandledRequests.length > 0
    })

    if(failedTest.length) {
      console.log("Failed tests:")
      failedTest.forEach(function(test){
        console.log(("elm-spec " + test.path + ":" + (test.id + 1)).red + (" # " + test.name).cyan)
      })
    }

    console.log(`
${allresults.length} files ${results.length} tests:
  ${steps} steps ${successfull} successfull ${failed} failed ${errored} errored
  ${requests} requests ${called} called ${notcalled} not called ${unhandled} unhandled
`)
    process.exit(failed || errored || notcalled || unhandled ? 1 : 0)
  })
});
