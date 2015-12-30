path = require 'path'
fs = require 'fs'
rimraf = require 'rimraf'
os = require 'os'

module.exports.createTempDirectory = (callback) ->
  testPath = path.join os.tmpdir(), 'fileTreeWalkerTest-' + (new Date()).getMilliseconds()
  fs.mkdir testPath, (err) ->
    if err?
      console.log 'Unable to create tenporary directory'
      throw err  
    callback(testPath)

module.exports.deleteTempDirectory = (name, done) ->
  rimraf name, (err) ->
    if err?
      console.log 'Unable to clean up temporary directory'
      throw err
    done()

module.exports.makeSubDir = (rootDir, name) ->
  return new Promise (resolve, reject) ->
    fs.mkdir path.join(rootDir, name), (err) ->
      if err?
        console.log 'Unable to create subDir'
        reject(err)
        return
      resolve()

module.exports.touchFile = (rootDir, name) ->
  module.exports.writeFile rootDir, name, ''

module.exports.writeFile = (rootDir, name, content) ->
  return new Promise (resolve, reject) ->
    fs.writeFile path.join(rootDir, name), content, (err) ->
      if err?
        console.log 'Unable to write file'
        reject(err)
        return
      resolve()
