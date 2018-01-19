import './options.scss'

const storage = chrome.storage.sync
const Elm = require('./elm/Options/Main.elm')
const app = Elm.Options.Main.embed(document.getElementById('options'))

document.body.onload = () => {
  app.ports.saveToStorage.subscribe(handleSaveToStorage)
  app.ports.clearStorage.subscribe(handleClearStorage)
  storage.get('teams', handleLoadFromStorage)
}

const handleLoadFromStorage = (data) => {
  app.ports.loadFromStorage
    .send(data.teams || [])
}

const handleSaveToStorage = (teams) => {
  storage.set({ teams: teams }, () => {
    app.ports.saveToStorageResult
      .send(!chrome.runtime.error)
  })
}

const handleClearStorage = () => {
  storage.remove('teams', () => {
    app.ports.clearStorageResult
      .send(!chrome.runtime.error)
  })
}
