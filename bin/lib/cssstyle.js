const CSSStyleDeclaration = require("cssstyle").CSSStyleDeclaration

const transition = require('./cssstyle/transition')
const animation = require('./cssstyle/animation')
const flex = require('./cssstyle/flex')

Object.defineProperties(CSSStyleDeclaration.prototype, transition)
Object.defineProperties(CSSStyleDeclaration.prototype, animation)
Object.defineProperties(CSSStyleDeclaration.prototype, flex)
