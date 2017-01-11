var LocalStorage = require('node-localstorage').LocalStorage
var which = require('npm-which')(__dirname)
var spawn = require('child_process').spawn
var temp = require('temp').track()
var globby = require('globby')
var colors = require('colors')
var jsdom = require('jsdom')

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

var run = function(file) {
  render(file, function(result, filename){
    if(result){
      console.log(result)
    } else {
      jsdom.env(
        "<html></html>",
        [__dirname + "/lib/raf.js",filename],
        { virtualConsole: jsdom.createVirtualConsole().sendTo(console) },
        function (err, window) {
          window.localStorage = new LocalStorage('./localStorageTemp');
          if(!window.Elm){
            console.log(`No Main found for: ${file}, skipping...`)
          } else {
            var app = window.Elm.Main.embed(window.document.body)
            app.ports.report.subscribe(function(results){
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

              results.forEach(function(test){
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
                console.log("")
              })

              console.log(`${results.length} tests: ${steps} steps ${successfull} successfull ${failed} failed ${errored} errored`)

              window.localStorage._deleteLocation()
            })
          }
        }
      )
    }
  })
}

globby(['spec/**Spec.elm']).then(paths => {
  paths.forEach(path => {
    run(path)
  })
});
