underscore = require 'underscore'

##
# A node in the tree datastructure.
# mainly consists out of helper functions
# @class TreeNode
module.exports = class TreeNode

  constructor: (@parent = null) ->
    @children = []
    @properties = []

  ##
  # Creates a new TreeNode and adds it as a child
  # @returns {TreeNode} the created child node
  addNewChild: =>
    child = new TreeNode(@)
    @children.push child
    return child

  ##
  # Adds a property to this node. If the key already exists,
  # the value will be overwritten
  # @param {String} key the name of the property
  # @param {Object} value arbitrary object representing the value
  setProperty: (key, value) =>
    @properties[key] = value

  ##
  # Query if the node has a given property
  # @param {String} key the name of the property
  # @param {Boolean} lookInParents if true, the property will be searched in parents if it does not exist
  # @returns a boolean value indicating whether the property exists
  hasProperty: (key, lookInParents = false) =>
    if @properties[key]?
      return true
    if lookInParents and @parent?
      return @parent.hasProperty key, true
    return false

  ##
  # Returns the value for a given key.
  # @param {String} key the name of the property
  # @param {Boolean} lookInParents if true, the property will be searched in parents if it does not exist
  # @returns the property or null, if it does not exist
  getProperty: (key, lookInParents = false) =>
    if @hasProperty key
      return @properties[key]
    if lookInParents and @parent?
      return @parent.getProperty key, true
    return null

  ##
  # Iterates over all own properties
  # @param {Function} callback the callback gets called with (key, value) for each property
  forEachProperty: (callback) =>
    for key, value of @properties
      callback(key, value)

  ##
  # Merges the properties of all parents and this
  # node into an object, which is then returned
  # @param {String} mergeStrategy either 'childWins' or 'parentWins', determines which property value to use if both parent and child have it
  flattenProperties: (mergeStrategy = 'childWins') =>
    mergedProperties = {}

    parentProperties = {}
    if @parent?
      parentProperties = @parent.flattenProperties mergeStrategy

    # Go through child properties and merge with parent
    @forEachProperty (key, value) =>
      mergedProperties[key] = @_mergeIndividualProperty(parentProperties[key], value, mergeStrategy)

    # Go through all keys of the parent that do not exist in the child
    for key, value of parentProperties
      if not mergedProperties[key]?
        mergedProperties[key] = value

    return mergedProperties

  ##
  # Merges an individual property
  _mergeIndividualProperty: (parentValue, childValue, mergeStrategy) =>
    # if the parent value is not defined, use child value
    if not parentValue?
      return childValue

    # Basic objects like strings and numbers are overwritten
    if underscore.isString(childValue) or underscore.isNumber(childValue) or underscore.isBoolean(childValue)
      if mergeStrategy == 'childWins'
        return childValue
      else
        return parentValue

    # Array elements are combined (parent values first)
    if underscore.isArray(childValue)
      return parentValue.concat(childValue)

    # Objects are merged by combining keys. Duplicate keys are overwritten
    # based on the merge strategy
    if underscore.isObject(childValue)
      base = {}
      merge = {}

      if mergeStrategy == 'childWins'
        base = underscore.clone(parentValue)
        merge = underscore.clone(childValue)
      else
        base = underscore.clone(childValue)
        merge = underscore.clone(parentValue)

      for key, value of merge
        base[key] = value

      return base

    # All cases should be covered above
    throw new Error("_mergeIndividualProperty failed to merge an unknown object type")

  ##
  # Returns all children or sub-children that do not have
  # child nodes of their own
  # @returns {TreeNode[]} array filled with all leaves
  getAllLeaves: =>
    leaves = []

    _addLeaves = (node) ->
      if node.children.length == 0
        leaves.push node
      else
        for child in node.children
          _addLeaves child

    _addLeaves(@)

    return leaves
