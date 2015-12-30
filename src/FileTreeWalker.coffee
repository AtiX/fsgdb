fs = require 'fs'
path = require 'path'
TreeNode = require './TreeNode'

##
# Parses a directory tree and creates document instances
# by using multiple parsers
# @class TreeWalker
module.exports = class TreeWalker

  constructor: (@parserInstances, @rootPath) ->
    return

  ##
  # Parses all folders beginning with the root directory
  # @returns {Promise} Promise that will resolve to the root node of the tree datastructure containing parsed data
  run: =>
    rootNode = new TreeNode()
    @parseFolder @rootPath, rootNode
    .then ->
      return rootNode

  ##
  # Lists all files and subdirectories, then
  # parses each file and recursively calls itself
  # on the subdirectories
  parseFolder: (fullPath, dirNode) =>
    dirNode.setProperty 'fullPath', fullPath
    if not dirNode.hasProperty 'dirName'
      dirNode.setProperty 'dirName', 'root'

    @listFolder(fullPath)
    .then (entries) =>
      # Create a child entry for each subfolder and parse subfolder
      childParsePromises = []
      for subdir in entries.subdirs
        subNode = dirNode.addNewChild()
        subNode.setProperty 'dirName', subdir

        subfolder = path.join fullPath, subdir
        childParsePromises.push @parseFolder subfolder, subNode

      # Parse this folder's files
      fileParsePromises = []
      for file in entries.files
        fileParsePromises.push @parseFile fullPath, file, dirNode

      return Promise.all(childParsePromises)
      .then ->
        return Promise.all(fileParsePromises)

  ##
  # Asks all loaded parserInstances to parse a given file
  parseFile: (directory, fileName, dirNode) =>
    parsePromises = []
    for parser in @parserInstances
      if parser.doesParse fileName
        parsePromises.push parser.parse(path.join(directory, fileName), dirNode)
    return Promise.all(parsePromises)

  ##
  # Lists all subfolders and files in a given directory
  listFolder: (dir) ->
    return new Promise (resolve, reject) ->
      fs.readdir dir, (error, entries) ->
        if error?
          # Gracefully fail and just ignore this directory
          console.log "Unable to list directory #{dir}:"
          console.log error
          entries = []

        result = {
          dir: dir
          subdirs: []
          files: []
        }

        _analyzeEntry = (entry) ->
          return new Promise (resolve)->
            filename = path.resolve dir, entry
            fs.stat filename, (error, stat) ->
              if error?
                console.log "Unable to stat #{filename}:"
                console.log error
                return

              if stat.isFile()
                result.files.push entry
              else if stat.isDirectory()
                result.subdirs.push entry
              
              resolve()

        promises = []
        for entry in entries
          promises.push _analyzeEntry entry

        p = Promise.all(promises)
        p = p.then -> resolve result
        p.catch (error) -> reject(error)
