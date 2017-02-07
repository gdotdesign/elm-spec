const camelCase = require('camelcase')

module.exports = (keys) => {
  return keys.reduce((memo, key) => {
    var obj =
      { set: function (value) { this._setProperty(key, value) },
        get: function () { return this.getPropertyValue(key) },
        enumerable: true,
        configurable: true
      }

    memo[key] = obj
    memo[camelCase(key)] = obj

    return memo
  }, {})
}
