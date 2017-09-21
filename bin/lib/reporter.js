'use strict'

const pad = require('pad')

class Reporter {
  constructor () {
    this.results = []
  }

  testTree (file) {
    var tree = new Map()
    var leaf = new Map()

    tree.set('◎ ' + file.file, leaf)

    file.tests.forEach(test => {
      var endLeaf = test.path.reduce((memo, item) => {
        if (!memo.has(item)) { memo.set(item, new Map()) }
        return memo.get(item)
      }, leaf)

      endLeaf.set(test.id, test)
    })

    return tree
  }

  get tests () {
    return this.results.reduce((memo, file) => {
      return memo.concat(file.tests)
    }, [])
  }

  isFailedTest (test) {
    var failedSteps = test.results.filter(step => {
      return step.outcome === 'fail' || step.outcome === 'error'
    }).length

    return failedSteps > 0 ||
           test.notMockedRequests.length > 0 ||
           test.unhandledRequests.length > 0
  }

  get failedTests () {
    return this.tests.filter(test => { return this.isFailedTest(test) })
  }

  get stepsCount () {
    return this.tests.reduce((memo, test) => {
      return memo + test.results.length
    }, 0)
  }

  get failedStepsCount () {
    return this.countSteps('fail')
  }

  get erroredStepsCount () {
    return this.countSteps('error')
  }

  get passedStepsCount () {
    return this.countSteps('pass')
  }

  get requestCount () {
    return this.tests.reduce((memo, test) => {
      return memo +
             test.mockedRequests.length +
             test.notMockedRequests.length +
             test.unhandledRequests.length
    }, 0)
  }

  get calledRequestCount () {
    return this.tests.reduce((memo, test) => {
      return memo + test.mockedRequests.length
    }, 0)
  }

  get notCalledRequestCount () {
    return this.tests.reduce((memo, test) => {
      return memo + test.notMockedRequests.length
    }, 0)
  }

  get unhandledRequestCount () {
    return this.tests.reduce((memo, test) => {
      return memo + test.unhandledRequests.length
    }, 0)
  }

  get exitCode () {
    return (
     this.failedStepsCount ||
     this.erroredStepsCount ||
     this.notCalledRequestCount ||
     this.unhandledRequestCount
    ) ? 1 : 0
  }

  countSteps (outcome) {
    return this.tests.reduce((memo, test) => {
      return memo + test.results.filter(result => {
        return result.outcome === outcome
      }).length
    }, 0)
  }

  reportSummary () {
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

  reportFaliures () {
    if (!this.failedTests.length) { return }

    var commands = this.failedTests.map(test => {
      var file = (this.results.filter(item => {
        return item.tests.indexOf(test) >= 0
      })[0] || { file: '' }).file

      return ' elm-spec ' + file + ':' + (test.id + 1)
    })

    var names = this.failedTests.map(test => {
      return ' # ' + test.name
    })

    var maxLength =
      Math.max.apply(null, commands.map(command => command.length))

    console.log('Failed tests:')

    commands.forEach((command, index) => {
      console.log(pad(command, maxLength).red + names[index].cyan)
    })

    console.log('')
  }

  report () {
    this.reportFaliures()
    this.reportSummary()
  }
}

module.exports = Reporter
