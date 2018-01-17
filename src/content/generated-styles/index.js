(() => {

  const head = document.head || document.getElementsByTagName('head')[0]
  const cfg = {
    tagId: 'jira-plus'
  }

  try {

    head.querySelector(`#${cfg.tagId}`).remove()

  } catch (e) {}

  let teams = [
    { name: "Backend (Dashboard)", color: "2e87fb" },
    { name: "Frontend", color: "fdac2a" },
  ]

  let css = teams.map(team => {
    return `
      .ghx-issue-compact .ghx-plan-extra-fields .ghx-extra-field[data-tooltip="Team: ${team.name}"],
      .ghx-issue .ghx-extra-fields .ghx-extra-field[data-tooltip="Team: ${team.name}"]{
        background: #${team.color};
      }
    `
  }).join('')

  let tag = document.createElement('style')
  tag.type = 'text/css'
  tag.id = cfg.tagId
  tag.appendChild(document.createTextNode(css))

  head.appendChild(tag)

})()
