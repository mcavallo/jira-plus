(() => {

  const head = document.head || document.getElementsByTagName('head')[0]
  const cfg = {
    tagId: 'jira-plus',
    baseCss: `
      .ghx-issue {
        border-radius: 0 0 3px 3px;
      }

      .ghx-issue-compact .ghx-plan-extra-fields,
      .ghx-issue .ghx-extra-fields {
      	top: 0;
      	position: absolute !important;
        margin: 0;
        overflow: hidden;
      }

      .ghx-issue .ghx-extra-fields .ghx-row {
        height: 100%;
        max-height: 100%;
      }

      .ghx-issue-compact .ghx-plan-extra-fields {
      	width: 3px;
      	height: 100%;
        left: 0px;
      }

      .ghx-issue .ghx-extra-fields {
      	height: 3px;
        top: -1px;
        left: -1px;
        right: -1px;
      }

      .ghx-issue-compact .ghx-plan-extra-fields .ghx-extra-field,
      .ghx-issue .ghx-extra-fields .ghx-extra-field {
        color: transparent;
        width: 100%;
        height: 100%;
        display: block;
      }
    `
  }

  try {
    head.querySelector(`#${cfg.tagId}`).remove();
  } catch (e) {}

  let teams = [
    { name: "Backend (Dashboard)", color: "4c97e3" },
    { name: "Frontend", color: "f5913f" },
  ]

  let css = cfg.baseCss + teams.map(team => {
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
