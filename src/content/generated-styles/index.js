(() => {

  const head = document.head || document.getElementsByTagName('head')[0]
  const cfg = {
    tagId: 'jira-plus'
  }

  try {

    head.querySelector(`#${cfg.tagId}`).remove()

  } catch (e) {}

  let teams = [
    { name: "Backend (Dashboard)", color: "4c97e3" },
    { name: "Frontend", color: "f5913f" },
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
