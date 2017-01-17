"use strict"

const indentString = require('indent-string')
const pad = require('pad')

class Reporter {
  /*
  results =
    [ { file = "relatie-path-to-file", tests = [{}] }
    ]
  */
  constructor(results) {
    this.results = results
  }

  get tests() {
    return this.results.reduce((memo, file) => {
      return memo.concat(file.tests)
    }, [])
  }

  get failedTests() {
    return this.tests.filter(test => {
      var failedSteps = test.results.filter(step => {
        return step.outcome === 'fail' || step.outcome === 'error'
      }).length

      return failedSteps > 0 ||
             test.notMockedRequests.length > 0 ||
             test.unhandledRequests.length > 0
    })
  }

  get stepsCount() {
    return this.tests.reduce((memo, test) => {
      return memo + test.results.length
    }, 0)
  }

  get failedStepsCount() {
    return this.countSteps('fail')
  }

  get erroredStepsCount() {
    return this.countSteps('error')
  }

  get passedStepsCount() {
    return this.countSteps('pass')
  }

  get requestCount() {
    return this.tests.reduce( (memo, test) => {
      return memo +
             test.mockedRequests.length +
             test.notMockedRequests.length +
             test.unhandledRequests.length
    }, 0)
  }

  get calledRequestCount() {
    return this.tests.reduce( (memo, test) => {
      return memo + test.mockedRequests.length
    }, 0)
  }

  get notCalledRequestCount() {
    return this.tests.reduce( (memo, test) => {
      return memo + test.notMockedRequests.length
    }, 0)
  }

  get unhandledRequestCount() {
    return this.tests.reduce( (memo, test) => {
      return memo + test.unhandledRequests.length
    }, 0)
  }

  get exitCode() {
    return (
     this.failedStepsCount ||
     this.erroredStepsCount ||
     this.notCalledRequestCount ||
     this.unhandledRequestCount
    ) ? 1 : 0
  }

  countSteps(outcome) {
    return this.tests.reduce( (memo, test) => {
      return memo + test.results.filter( result => {
        return result.outcome == outcome
      }).length
    }, 0)
  }

  reportSummary() {
    console.log(
      `${this.results.length} files ${this.tests.length} tests:`
    )

    console.log(
      ` ${this.stepsCount} steps:`,
      `${this.passedStepsCount} successfull,`,
      `${this.failedStepsCount} failed,`,
      `${this.erroredStepsCount} errored`
    )

    console.log(
      ` ${this.requestCount} requests:`,
      `${this.calledRequestCount} called,`,
      `${this.notCalledRequestCount} not called,`,
      `${this.unhandledRequestCount} unhandled`
    )
  }

  reportFaliures() {
    if(!this.failedTests.length) { return }

    var commands = this.failedTests.map( test => {
      var file = (this.results.filter( item => {
        return item.tests.indexOf(test) >= 0
      })[0] || { file: "" }).file

      return "elm-spec " + file + ":" + (test.id + 1)
    })

    var names = this.failedTests.map( test => {
      return " # " + test.name
    })

    var maxLength =
      Math.max.apply(null, commands.map( command => command.length ))

    console.log('Failed tests:')

    commands.forEach( (command, index) => {
      console.log( pad(command, maxLength).red + names[index].cyan )
    })

    console.log('')
  }

  report() {
    this.reportFaliures()
    this.reportSummary()
  }
}

class DocumentationReporter extends Reporter {
  report() {
    this.results.forEach(file => {
      file.tests.forEach(test => {
        var indent = (test.indentation * 2) - 2

        console.log(indentString(test.name.bold, indent))

        test.results.forEach(function(result){
          switch(result.outcome) {
            case "pass":
              console.log(indentString(result.message.green, indent + 2))
              break
            case "fail":
              console.log(indentString(result.message.red, indent + 2))
              break
            case "error":
              console.log(indentString(result.message.bgRed, indent + 2))
          }
        })

        if(test.mockedRequests.length ||
           test.notMockedRequests.length ||
           test.unhandledRequests.length) {
          console.log(indentString("Requests:", indent + 2))
          test.mockedRequests.forEach(function(req){
            console.log(indentString(("✔ " + req.method + " - " + req.url).green, indent + 3))
          })

          test.notMockedRequests.forEach(function(req){
            console.log(indentString(("✘ " + req.method + " - " + req.url).red, indent + 3))
          })

          test.unhandledRequests.forEach(function(req){
            console.log(indentString(("? " + req.method + " - " + req.url).bgRed, indent + 3))
          })
        }

        console.log("")
      })
    })
    super.report()
  }
}

class ProgressReporter extends Reporter {
  report() {
    var dots = this.tests.map( test => {
      return this.failedTests.indexOf(test) == -1 ? ".".green : "F".red
    })

    console.log(dots.join("") + "\n")
    super.report()
  }
}

module.exports = ProgressReporter
