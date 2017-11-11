module.exports = function mentions(options) {

  let opts = Object.assign({
    domain: '???.atlassian.net'
  }, options)

  return md => {
    md.inline.ruler.after('text', 'mentions', rule(md, opts), {alt: []})
  }

}

function rule(md, options) {
  return (state, silent) => {

    let end,
        pos,
        name,
        start = state.pos,
        max = state.posMax,
        marker = state.src.charCodeAt(start)

    if (marker !== 0x5B/* [ */) { return false }

    end = findMentionEnd(state, start + 1)

    if (end === -1) { return false }

    if (!silent) {

      pos = end + 1
      name = state.src.slice(start + 2, end) /* [~name] */

      state.pos = start + 2
      state.posMax = end

      state.push({
        type: 'link_open',
        href: `https://${options.domain}/secure/ViewProfile.jspa?name=${name}`,
        title: name,
        level: state.level++
      })

      state.push({
        type: 'text',
        content: '@' + name,
        level: state.level
      })

      state.push({
        type: 'link_close',
        level: --state.level
      })

    }

    state.pos = pos
    state.posMax = max

    return true

  }
}

function findMentionEnd(state, start) {

  let found,
      marker = state.src.charCodeAt(start),
      pos = state.pos,
      max = state.posMax

  if (marker !== 0x7e/* ~ */) { return -1 }

  while (pos < max) {
    marker = state.src.charCodeAt(pos)

    if (marker === 0x5D /* ] */) {
      found = pos
      break
    }

    pos++
  }

  return found ? found : -1

}
