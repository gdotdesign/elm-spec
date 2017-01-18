const transformKeys = require('./transform-keys')

module.exports =
  transformKeys(
    [ 'transition'
    , 'transition-delay'
    , 'transition-duration'
    , 'transition-property'
    , 'transition-timing-function'
    ]
  )
