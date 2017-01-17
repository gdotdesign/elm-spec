"use strict"

const Reporter = require('./reporter')

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
