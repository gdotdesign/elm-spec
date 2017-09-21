'use strict'

const Reporter = require('./reporter')

class ProgressReporter extends Reporter {
  reportFile (result) {
    var dots = result.tests.map(test => {
      return this.isFailedTest(test) ? 'F'.red : '.'.green
    })

    process.stdout.write(dots.join(''))

    this.results.push(result)
  }

  reportResults () {
    console.log('\n')
    this.report()
  }
}

module.exports = ProgressReporter
