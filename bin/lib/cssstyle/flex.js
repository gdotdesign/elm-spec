const transformKeys = require('./transform-keys')

module.exports =
  transformKeys(
    [ 'justify-content',
      'flex-direction',
      'align-content',
      'align-items',
      'align-selft',
      'flex-shrink',
      'flex-basis',
      'flex-grow',
      'flex-wrap',
      'flex-flow',
      'flex',
      'order'
    ]
  )
