"use strict"

const indentString = require('indent-string')
const Reporter = require('./reporter')

class DocumentationReporter extends Reporter {
  reportMap(map, newLine = false ) {
    var result = []

    map.forEach((value, key) => {
      if(value instanceof Map) {
        result.push(key)
        result.push(indentString(this.reportMap(value), 2))
        if(newLine) { result.push("") }
      } else {
        result.push(this.reportTest(value))
      }
    })

    return result.join("\n")
  }

  reportTest(test) {
    var isFailed =
      test.results.filter(step => step.outcome != 'pass').length ||
      test.notMockedRequests.length ||
      test.unhandledRequests.length

    var prefix = isFailed ? "✘" : "✔"

    var result = [prefix + " " + test.name]

    test.results.forEach(step =>{
      switch(step.outcome) {
        case "pass":
          result.push(indentString(step.message.green, 2))
          break
        case "fail":
          result.push(indentString(step.message.red, 2))
          break
        case "error":
          result.push(indentString(step.message.bgRed, 2))
      }
    })

    if(test.mockedRequests.length ||
       test.notMockedRequests.length ||
       test.unhandledRequests.length) {

      result.push(indentString("Requests:", 2))

      test.mockedRequests.forEach( req => {
        result.push(indentString(("✔ " + req.method + " - " + req.url).green, 4))
      })

      test.notMockedRequests.forEach( req => {
        result.push(indentString(("✘ " + req.method + " - " + req.url).red, 4))
      })

      test.unhandledRequests.forEach( req => {
        result.push(indentString(("? " + req.method + " - " + req.url).bgRed, 4))
      })
    }

    return result.join("\n")
  }

  report() {
    console.log(this.reportMap(this.tree, true))
    super.report()
  }
}

module.exports = DocumentationReporter
