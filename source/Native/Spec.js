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
        return error("Element not found: " + bold(selector))
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
        return pass("Attribute " + bold(attribute) + " of element " + bold(selector) + " contains text " + bold(value))
      } else {
        return fail("Attribute " + bold(attribute) + " of element " + bold(selector) + " does not contain text " + bold(value))
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

  var elementPresent = function(selector){
    return task(function(callback){
      try {
        var el = document.querySelector(selector)
        if(el){
          return callback(succeed(pass("Element " + bold(selector) + " is present")))
        } else {
          return callback(succeed(fail("Element " + bold(selector) + " is not present")))
        }
      } catch (e) {
        return callback(succeed(error(e.toString())))
      }
    })
  }

  var elementVisible = function(selector){
    return taskWithElement(selector, function(element){
      var result = testVisibility(element, selector)
      if(result) {
        return result;
      } else {
        return pass("Element " + bold(selector) + " should be visible (no CSS used to hide it)")
      }
    })
  }

  var testVisibility = function(element, selector){
    if(!element) { return null }
    var style = window.getComputedStyle(element)
    if (style.display === 'none'){
      return fail("Element " + bold(selector) + " is hidden by "+ bold('display: none'))
    } else if (parseFloat(style.opacity) === 0) {
      return fail("Element " + bold(selector) + " is hidden by "+ bold('opacity: 0'))
    } else if (style.visibility === 'hidden') {
      return fail("Element " + bold(selector) + " is hidden by "+ bold('visiblity: hidden'))
    } else if (style.zIndex != "auto" && parseInt(style.zIndex) < 0) {
      return fail("Element " + bold(selector) + " is hidden by "+ bold('z-index: ' + style.zIndex))
    } else if (testVisibility(element.parentElement, "")) {
      return fail("Element " + bold(selector) + " is hidden by parent element.")
    } else {
      return null;
    }
  }

  var titleContains = function(text) {
    return task(function(callback){
      var title = document.title.toString()
      if(title.indexOf(text) >= 0) {
        callback(succeed(pass("Title " + bold(title) + " contains text " + bold(text))))
      } else {
        callback(succeed(fail("Title " + bold(title) + " does not contain text " + bold(text))))
      }
    })
  }

  var titleEquals = function(text) {
    return task(function(callback){
      var title = document.title.toString()
      if(title === text) {
        callback(succeed(pass("Title equals " + bold(text))))
      } else {
        callback(succeed(fail("Title " + bold(title) + " does not equal " + bold(text))))
      }
    })
  }

  var urlContains = function(text) {
    return task(function(callback){
      var url = window.location.toString()
      if(url.indexOf(text) >= 0) {
        callback(succeed(pass("URL " + bold(url) + " contains text " + bold(text))))
      } else {
        callback(succeed(fail("URL " + bold(url) + " does not contain text " + bold(text))))
      }
    })
  }

  var urlEquals = function(text) {
    return task(function(callback){
      var url = window.location.toString()
      if(url === text) {
        callback(succeed(pass("URL equals " + bold(text))))
      } else {
        callback(succeed(fail("URL " + bold(url) + " does not equal " + bold(text))))
      }
    })
  }

  var getAttribute = function(attribute, selector) {
    return taskWithElement(selector, function(element){
      return element.getAttribute(attribute)
    })
  }

  var click = function(selector){
    return taskWithElement(selector, function(element){
      element.click()
      return pass("Clicked: " + bold(selector))
    })
  }

  var getTitle = task(function(callback){
    callback(succeed(document.title.toString()))
  })

  var getUrl = task(function(callback){
    callback(succeed(window.location.toString()))
  })

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
    elementPresent: elementPresent,
    elementVisible: elementVisible,
    titleContains: titleContains,
    styleEquals: F3(styleEquals),
    titleEquals: titleEquals,
    urlContains: urlContains,
    urlEquals: urlEquals,
    getTitle: getTitle,
    getUrl: getUrl,
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
