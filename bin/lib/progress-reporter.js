"use strict"

const indentString = require('indent-string')
const pad = require('pad')

class Reporter {
  constructor(results) {
    this.results = results
  }

  get tree() {
    var tree = new Map()

    this.results.forEach(file => {
      var leaf = new Map()
      tree.set("◎ " + file.file, leaf)

      file.tests.forEach(test => {
        var endLeaf = test.path.reduce((memo, item) => {
          if(!memo.has(item)) { memo.set(item, new Map()) }
          return memo.get(item)
        }, leaf)

        endLeaf.set(test.id, test)
      })
    })

    return tree
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

      return " elm-spec " + file + ":" + (test.id + 1)
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

class ProgressReporter extends Reporter {
  report() {
    var dots = this.tests.map( test => {
      return this.failedTests.indexOf(test) == -1 ? ".".green : "F".red
    })

    console.log(dots.join("") + "\n")
    super.report()
  }
}

module.exports = DocumentationReporter
