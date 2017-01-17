"use strict"

var which = require('npm-which')(__dirname)
var spawn = require('child_process').spawn
var temp = require('temp').track()

var elmExecutable = which.sync('elm-make')

module.exports = function(file, callback) {
  var filename = temp.openSync({ suffix: '.js' }).path

  var args =
    [file, '--output', filename, '--yes']

  var result = ''
  var command

  command = spawn(elmExecutable, args)

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
