import { removeStyleElement, addStyleElement } from './../utils/styles'

(() => {

  const storage = chrome.storage.sync
  const head = document.head || document.getElementsByTagName('head')[0]
  const cfg = {
    tagId: 'jira-plus'
  }

  const prepareCSS = (teams) => {
    return teams.map(team => {
      return `
        .ghx-issue-compact .ghx-plan-extra-fields .ghx-extra-field[data-tooltip="Team: ${team.name}"],
        .ghx-issue .ghx-extra-fields .ghx-extra-field[data-tooltip="Team: ${team.name}"]{
          background: ${team.color};
        }
      `
    }).join('')
  }

  const renderNewStyles = (head, id, teams) => {
    removeStyleElement(head, id)
    addStyleElement(head, id, prepareCSS(teams))
  }

  chrome.storage.onChanged.addListener((changes, namespace) => {
    if (namespace !== 'sync' || !changes.teams) {
      return;
    }

    renderNewStyles(head, cfg.tagId, changes.teams.newValue)
  })

  storage.get('teams', (data) => {
    if (!data || !data.teams || !data.teams.length) {
      return;
    }

    renderNewStyles(head, cfg.tagId, data.teams)
  })

})()
