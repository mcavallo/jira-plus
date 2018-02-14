import { intersection, last, flow, split, toString, toInteger, map } from 'lodash/fp'

const debounce = {
  timeout: null,
  wait: 500
}

const watchWhitelist = [
  'ghx-columns',
  'ghx-column',
  'ghx-issue'
]


export const handleSubtreeModified = (target, swimlaneId, limitClass) => {
  if (!isEventAllowed(target)) {
    return
  }

  clearTimeout(debounce.timeout)
  debounce.timeout = setTimeout(() => {
    applyLimits(swimlaneId, limitClass)
  }, debounce.wait)
}


const isEventAllowed = (node) =>
  intersection(watchWhitelist, node.classList).length > 0


const applyLimits = (swimlaneId, limitClass) => {
  let limits = getColumnLimits()

  limits.forEach((limit, index) => {
    let status = limit > 0 && getCardCount(swimlaneId, index) > limit
    setColumnLimitClass(swimlaneId, index, limitClass, status)
  })
}


const setColumnLimitClass = (swimlaneId, index, limitClass, status) => {
  let laneColumn = document.querySelector(`.ghx-swimlane[swimlane-id="${swimlaneId}"] .ghx-column:nth-child(${index + 1})`)
  let headerColumn = document.querySelector(`#ghx-column-headers .ghx-column:nth-child(${index + 1})`)

  laneColumn.classList.toggle(limitClass, status)
  headerColumn.classList.toggle(limitClass, status)
}


const getCardCount = (swimlaneId, index) =>
  document
    .querySelectorAll(`.ghx-swimlane[swimlane-id="${swimlaneId}"] .ghx-column:nth-child(${index + 1}) .ghx-issue`)
    .length


const getColumnLimits = () =>
  flow(
    nodeListToArray,
    map(mapColumnLimit)
  )(document.querySelectorAll('#ghx-column-headers > .ghx-column'))


const mapColumnLimit = (column) => {
  let limitNode = column.childNodes[0].childNodes[1];

  if (!limitNode || !limitNode.childNodes.length) {
    return 0
  }

  return parseLimitValue(limitNode.childNodes[0].childNodes[0].nodeValue)
}


const parseLimitValue =
  flow(toString, split(' '), last, toInteger)


const nodeListToArray = (nodeList) =>
  [].slice.call(nodeList)

module.export
