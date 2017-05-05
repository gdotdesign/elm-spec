const transformKeys = require('./transform-keys')

module.exports =
  transformKeys(
    [ 'animation',
      'animation-delay',
      'animation-duration',
      'animation-direction',
      'animation-iteration-count',
      'animation-fill-mode',
      'animation-name',
      'animation-play-state',
      'animation-timing-function'
    ]
  )
