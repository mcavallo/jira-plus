import './options.scss'

var storage = chrome.storage.sync

var Elm = require('./elm/Options/Main.elm')
var app = Elm.Options.Main.embed(document.getElementById('options'))

app.ports.saveToStorage.subscribe(handleSaveToStorage)

document.body.onload = function() {
  storage.get('teams', handleLoadFromStorage)
}

function handleSaveToStorage(teams) {
  storage.set({ teams: teams }, function() {
    app.ports.saveToStorageResult.send(
      !!chrome.runtime.error ? 'FAIL' : 'OK'
    );
  });
}

function handleLoadFromStorage(data) {
  app.ports.loadFromStorage.send(data.teams);
}
