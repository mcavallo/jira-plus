import { intersection, last, flow, split, toString, toInteger, map } from 'lodash/fp'
import { handleSubtreeModified } from './column-limits'
import { removeStyleElement, addStyleElement } from './../utils/styles'

(() => {

  const head = document.head || document.getElementsByTagName('head')[0]
  const cfg = {
    swimlaneId: 14,
    limitClass: 'jira-plus-limit-reached',
    tagId: 'jira-plus-column-limits'
  }

  const init = () => {
    if (!document.querySelector(`.ghx-swimlane[swimlane-id="${cfg.swimlaneId}"]`)) {
      return
    }

    const css = `
      body.adg3 .ghx-column-headers .ghx-column.ghx-busted-max h2,
      body.adg3 .ghx-columns .ghx-column.ghx-busted-max h2,
      body.adg3 .ghx-column-headers .ghx-column.ghx-busted-max .ghx-qty,
      body.adg3 .ghx-columns .ghx-column.ghx-busted-max .ghx-qty,
      body.adg3 .ghx-column-headers .ghx-column.ghx-busted-max .ghx-constraint,
      body.adg3 .ghx-columns .ghx-column.ghx-busted-max .ghx-constraint,
      body.adg3 .ghx-column-headers .ghx-column.ghx-busted-max .ghx-icon-collapse-column,
      body.adg3 .ghx-columns .ghx-column.ghx-busted-max .ghx-icon-collapse-column {
        color: #5E6C84;
      }

      body.adg3 .ghx-column-headers .ghx-column.ghx-busted-max {
        background: #F4F5F7;
      }

      body.adg3 .ghx-column-headers .ghx-column.ghx-busted-max,
      body.adg3 .ghx-columns .ghx-column.ghx-busted-max {
        background: #F4F5F7;
      }
    `

    addStyleElement(head, cfg.tagId, css)

    document
      .getElementById('ghx-pool')
      .addEventListener('DOMSubtreeModified', (e) =>
        handleSubtreeModified(e.target, cfg.swimlaneId, cfg.limitClass)
      )
  }

  setTimeout(init, 1)

})()
