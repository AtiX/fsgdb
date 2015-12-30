Parser = require './Parser'
marked = require 'marked'
fs = require 'fs'
path = require 'path'

module.exports = class MarkdownParser extends Parser

  ##
  # Only parse .md files
  doesParse: (filename) ->
    return Parser.hasExtension filename, ['md']

  ##
  # Parses markdown. A file 'mytext.md' will be added to
  # the dirNode as dirNode.markdown.mytext = html
  parse: (filename, dirNode) =>
    return new Promise (resolve, reject) ->
      fs.readFile filename, 'utf8', (error, data) ->
        if error?
          reject(error)
          return

        markdown = marked(data)
        entryName = path.basename filename, '.md'

        if not dirNode.hasProperty 'markdown'
          dirNode.setProperty 'markdown', {}

        mdproperty = dirNode.getProperty 'markdown'
        mdproperty[entryName] = markdown

        resolve()
