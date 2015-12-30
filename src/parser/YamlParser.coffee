Parser = require './Parser'
yaml = require 'js-yaml'
fs = require 'fs'
path = require 'path'

module.exports = class MarkdownParser extends Parser
  ##
  # Only parse yaml files
  doesParse: (filename) ->
    return Parser.hasExtension filename, ['yml']

  ##
  # Parses yaml data. Per default, the parsed object will be added with the key being
  # the yaml filename, except for 'metadata.yml', whose subobjects will be added to the
  # node directly
  parse: (filename, dirNode) =>
    return new Promise (resolve, reject) ->
      fs.readFile filename, 'utf8', (error, data) ->
        if error?
          reject(error)
          return

        parsedYaml = yaml.safeLoad(data)
        entryName = path.basename filename, '.yml'

        if entryName == 'metadata'
          for key, value of parsedYaml
            dirNode.setProperty key, value
        else
          dirNode.setProperty entryName, parsedYaml

        resolve()
