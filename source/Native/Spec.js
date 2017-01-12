var _gdotdesign$elm_spec$Native_Spec = function() {
  var task = _elm_lang$core$Native_Scheduler.nativeBinding
  var succeed = _elm_lang$core$Native_Scheduler.succeed
  var tuple0 = _elm_lang$core$Native_Utils.Tuple0

  var error = function(message){
    return { ctor: 'Error', _0: message }
  }

  var pass = function(message){
    return { ctor: 'Pass', _0: message }
  }

  var fail = function(message){
    return { ctor: 'Fail', _0: message }
  }

  var bold = function(message) {
    return '\x1b[1m' + message + '\x1b[21m'
  }

  var withElement = function(selector, method) {
    try {
      var el = document.querySelector(selector)
      if(el){
        return method(el)
      } else {
        return error("Element not found: " + selector)
      }
    } catch (e) {
      return error(e.toString())
    }
  }

  var taskWithElement = function(selector, method) {
    return task(function(callback){
      callback(succeed(withElement(selector, method)))
    })
  }

  var containsText = function(value, selector){
    return taskWithElement(selector, function(element){
      if(element.textContent.indexOf(value) >= 0) {
        return pass("Element " + bold(selector) + " contains text " + bold(value))
      } else {
        return fail("Element " + bold(selector) + " does not contain text " + bold(value))
      }
    })
  }

  var attributeContains = function(attribute, value, selector){
    return taskWithElement(selector, function(element){
      var attributeValue = element.getAttribute(attribute) || ''
      if(attributeValue.indexOf(value) >= 0){
        return pass("Attribute " + bold(attribute) + " of element " + bold(selector) + " contains " + bold(value))
      } else {
        return fail("Attribute " + bold(attribute) + " of element " + bold(selector) + " does not contain " + bold(value))
      }
    })
  }

  var attributeEquals = function(attribute, value, selector){
    return taskWithElement(selector, function(element){
      var attributeValue = element.getAttribute(attribute) || ''
      if(attributeValue.toString() === value) {
        return pass("Attribute " + bold(attribute) + " of element " + bold(selector) + " equals " + bold(value))
      } else {
        return fail("Attribute " + bold(attribute) + " of element " + bold(selector) + " does not equal " + bold(value))
      }
    })
  }

  var classPresent = function(klass, selector) {
    return taskWithElement(selector, function(element){
      if(element.classList.contains(klass)){
        return pass("Element " + bold(selector) + " has class " + bold(klass))
      }else{
        return fail("Element " + bold(selector) + " does not have class " + bold(klass))
      }
    })
  }

  var styleEquals = function(style, value, selector) {
    return taskWithElement(selector, function(element){
      if(window.getComputedStyle(element)[style].toString() === value){
        return pass("Element " + bold(selector) + " has style " + bold(style) + " with value " + bold(value))
      }else{
        return fail("Element " + bold(selector) + " does not have style " + bold(style) + " with value " + bold(value))
      }
    })
  }

  var getAttribute = function(attribute, selector) {
    return taskWithElement(selector, function(element){
      return succeed(element.getAttribute(attribute))
    })
  }

  var click = function(selector){
    return taskWithElement(selector, function(element){
      element.click()
      return pass("Clicked: " + bold(selector))
    })
  }

  var raf = function(){
    return task(function(callback){
      requestAnimationFrame(function(){
        callback(succeed(tuple0))
      })
    })
  }

  return {
    attributeContains: F3(attributeContains),
    attributeEquals: F3(attributeEquals),
    classPresent: F2(classPresent),
    containsText: F2(containsText),
    getAttribute: F2(getAttribute),
    styleEquals: F3(styleEquals),
    ansiToHtml: function(value){
      return value.replace(/\x1b\[1m(.*?)\x1b\[21m/g, "<b>$1</b>")
    },
    report: function(data){
      if(window._elmSpecReport){
        window._elmSpecReport(data)
      }
      return task(function(){succeed(tuple0)})
    },
    click: click,
    raf: raf()
  }
}()
