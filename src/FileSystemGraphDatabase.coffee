FileTreeWalker = require './FileTreeWalker'

##
# This class represents the database instance
module.exports = class FileSystemGraphDatabase

  ##
  # Expects an config object
  # @param {Object} config Configuration object
  # @param {String} config.path Root path where all md/yml files are stored
  constructor: (@config) ->
    @parserInstances = []

  ##
  # Allows to register an instance of a file parser.
  # All registerd parsers are then used when load()-ing files from
  # disk.
  # @param {FileParser} parserInstance the instance of the parser - or class name, if the parser requires no manual initialization
  # @param {Object} parserOptions additional options when initializing the parser via class name
  registerParser: (parserInstance, parserOptions = {}) ->
    if 'string' == typeof parserInstance
      # Try to require class and instanciate
      try
        ParserClass = require './parser/' + parserInstance
        @parserInstances.push new ParserClass(parserOptions)
        return
      catch e
        throw new Error("Unable to load parser by class name: #{e}")
    else
      # Assume it's a parser instance
      @parserInstances.push parserInstance

  ##
  # Loads documents from disk
  load: =>
    # Create tree walker and parse all files
    walker = new FileTreeWalker(@parserInstances, @config.path)
    return walker.run()
    .then (rootNode) =>
      @rootNode = rootNode
      return @rootNode

