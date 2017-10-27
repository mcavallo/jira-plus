const fs = require('fs')
const path = require('path')
const exec = require('child_process').exec
const del = require('del')
const xml2js = require('xml2js')
const compareVersions = require('compare-versions')

const paths = {
  root: path.resolve('./'),
  src: path.resolve('./src'),
  releases: path.resolve('./releases'),
  key: path.resolve('./key.pem'),
  updatesXml: path.resolve(`./releases/updates.xml`),
  readme: path.resolve(`./README.md`)
}

const manifest = require(path.join(paths.src, 'manifest.json'))


const releaseLink = (version) => {
  return `https://raw.githubusercontent.com/mcavallo/jira-plus/master/releases/${version}.crx`
}


const updateTemplate = (version) => {

  return {
    $: {
      codebase: releaseLink(version),
      version: version
    }
  }

}


const readUpdates = () => new Promise((resolve, reject) => {

  let xml = fs.readFileSync(paths.updatesXml)
  let parser = new xml2js.Parser()

  parser.parseString(xml, (err, updates) => {

    let [last] = updates.gupdate.app[0].updatecheck.slice(-1)
    let latestVersion = last.$.version

    if (compareVersions(manifest.version, latestVersion) !== 1) {
      return reject(`Manifest version (${manifest.version}) must be greater than the latest update (${latestVersion})`)
    }

    updates.gupdate.app[0].updatecheck = [updateTemplate(manifest.version)]
    resolve(updates)

  })

})


const packExtension = (updates) => new Promise((resolve, reject) => {

  let cmd = [
    `/Applications/Google\\ Chrome.app/Contents/MacOS/Google\\ Chrome`,
    `--pack-extension="${paths.src}"`,
    `--pack-extension-key="${paths.key}"`
  ].join(' ')

  exec(cmd, (error, stdout, stderr) => {

    if (error) {
      return reject('Build failed.')
    }

    console.log('Build OK', manifest.version)
    resolve(updates)

  })

})


const clearOldReleases = (updates) => new Promise((resolve, reject) => {

  del([path.join(paths.releases, '*.crx')]).then(paths => {
    resolve(updates)
  });

})


const movePackedExtension = (updates) => new Promise((resolve, reject) => {

  let src = path.join(paths.root, 'src.crx')
  let dest = path.join(paths.releases, `${manifest.version}.crx`)

  fs.rename(src, dest, err => {

    if (err) {
      return reject(err)
    }

    resolve(updates)

  })

})


const registerUpdate = (updates) => new Promise((resolve, reject) => {

    let builder = new xml2js.Builder({
      xmldec: {
        'version': '1.0',
        'encoding': 'UTF-8'
      }
    })

    let xmlContent = builder.buildObject(updates)

    fs.writeFile(paths.updatesXml, xmlContent, (err) => {

      if (err) {
        return reject(`Updates file couldn't be written`)
      }

      resolve(updates)

    })

})


const updateReadme = (updates) => new Promise((resolve, reject) => {

  let readmeContent = fs.readFileSync(paths.readme, 'utf-8')

  readmeContent = readmeContent.replace(
    /^\[latest-release\]:.*$/m,
    `[latest-release]: ${releaseLink(manifest.version)}`
  )

  fs.writeFile(paths.readme, readmeContent, (err) => {

    if (err) {
      return reject(`Readme file couldn't be written`)
    }

    resolve(updates)

  })

})


readUpdates()
  .then(packExtension)
  .then(clearOldReleases)
  .then(movePackedExtension)
  .then(registerUpdate)
  .then(updateReadme)
  .then(() => {
    console.log(`🚀`)
  })
  .catch(err => {
    console.error(err)
  })
