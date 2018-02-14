
export const removeStyleElement = (head, id) => {
  try {
    head.querySelector(`#${id}`).remove()
  } catch (e) {}
}


export const addStyleElement = (head, id, css) => {
  let tag = document.createElement('style')
  tag.type = 'text/css'
  tag.id = id
  tag.appendChild(document.createTextNode(css))

  head.appendChild(tag)
}
