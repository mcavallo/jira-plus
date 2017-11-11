import Remarkable from 'remarkable'
import mentions from '../markdown/lib/mentions'

var md = new Remarkable('full', {
  html: false,
  breaks: true,
  linkify: true,
  typographer: true
})

md.use(mentions({
  domain: 'adjustcom.atlassian.net'
}))

var listeners = [],
    doc = window.document,
    MutationObserver = window.MutationObserver || window.WebKitMutationObserver,
    observer

function ready(selector, fn) {
  // Store the selector and callback to be monitored
  listeners.push({
    selector: selector,
    fn: fn
  })

  if (!observer) {
    // Watch for changes in the document
    observer = new MutationObserver(check)
    observer.observe(doc.documentElement, {
      childList: true,
      subtree: true
    })
  }

  // Check if the element is currently in the DOM
  check()
}

function check() {
  // Check the DOM for elements matching a stored selector
  for (var i = 0, len = listeners.length, listener, elements; i < len; i++) {
    listener = listeners[i]
    // Query for elements matching the specified selector
    elements = doc.querySelectorAll(listener.selector)
    for (var j = 0, jLen = elements.length, element; j < jLen; j++) {
      element = elements[j]
      // Make sure the callback isn't invoked with the
      // same element more than once
      if (!element.ready) {
        element.ready = true
        // Invoke the callback with the element
        listener.fn.call(element, element)
      }
    }
  }
}

function setMarkdownContent(el) {
  if (el.classList.contains('markdown-ready')) {
    return
  }
  console.log(el.innerText)
  el.classList.add('markdown-ready')
  el.innerHTML = md.render(el.innerText)
}

ready('.user-content-block', setMarkdownContent)
ready('.activity-comment .action-body', setMarkdownContent)
