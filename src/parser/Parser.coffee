##
# Abstract base class to be implemented by sublcasses.
# A Parser should parse files of one or more types and
# generate information out of it
# @class Parser
module.exports = class Parser

  ##
  # Parses one file
  # @param {String} filename Full path to the file to be parsed
  # @param {Object} dirNode Object to attach extracted information to
  # @returns {Promise} Returns a promise that eventually resolves when all information is attached to dirNode
  parse: (filename, dirNode) =>
    throw new Error("A sublass must implement parse()")

  ##
  # Retunrs whether the parser would parse the given file
  # @returns {Boolean} true, if the parser would parse the given file
  doesParse: (filename) =>
    throw new Error("A sublass must implement doesParse()")

  ##
  # A helper method for subclasses:
  # returns true if the file specified has one of the
  # given extensions, false otherwise
  # @param {String} filename The filename or full path to the file
  # @param {String[]} extensions File extensions (without '.')
  @hasExtension: (filename, extensions) ->
    fileExt = filename.split('.').pop()

    for extension in extensions
      if fileExt == extension
        return true
    return false
