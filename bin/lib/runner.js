"use strict"

const LocalStorage = require('node-localstorage').LocalStorage
const indentString = require('indent-string')
const elmMake = require('./elm-make')
const temp = require('temp').track()
const colors = require('colors')
const jsdom = require('jsdom')
const fs = require('fs')

module.exports = function(file, testId) {
  return (callback => {
    elmMake(file, (result, filename) => {
      if(result){
        console.log("Failed to compile " + filename.bold + ":")
        console.log(indentString(result, 2))
        process.exit(1)
      } else {
        var html = `
          <html>
            <head>
              <base href='http://localhost:8080/'></base>
              <title>Elm-Spec</title>
            </head>
          </html>
        `

        var libContents = `
          window.requestAnimationFrame = setTimeout;
          window._elmSpecTestId = ${testId};
        `
        var libFile = temp.openSync({ suffix: '.js' }).path
        fs.writeFileSync(libFile, libContents)

        jsdom.env({
          virtualConsole: jsdom.createVirtualConsole().sendTo(console),
          cookieJar: jsdom.createCookieJar(),
          url: "http://localhost:8080/",
          html: html,
          scripts: [
            "file:///" + libFile,
            "file:///" + filename
          ],
          done: (err, window) => {
            window.sessionStorage = new LocalStorage(temp.mkdirSync())
            window.localStorage = new LocalStorage(temp.mkdirSync())

            if(!window.Elm){
              console.log(`No Main found for: ${file}, exiting...`.red)
              process.exit(1)
            } else {
               window.Elm.Main.embed(window.document.body)
              window._elmSpecReport = function(results){
                callback(null, { file: file, tests: results })
              }
            }
          }
        })
      }
    })
  })
}
