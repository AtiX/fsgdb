underscore = require 'underscore'

##
# Allows to query the graph database in a LINQ-like chainable way.
# @class Query
module.exports = class Query

  ##
  # Expects a single node or an array of nodes to perform
  # the query on it
  constructor: (@nodes, @filterChain = []) ->
    if not underscore.isArray(@nodes)
      @nodes = [@nodes]

  ##
  # Filters the result based on an user-specified filter function, the filter function has to return true or false.
  # If a node matches the filter, the node is selected and the search is stopped. Else, its children are searched
  # for matching sub-nodes.
  # The filter callback should accept the parameters (nodeProperties, node) and  use the nodeProperties
  # object to check properties instead using the node functions
  filter: (filterCallback) =>
    matchingNodes = []

    filterNode = (node) ->
      # Add matching node
      if filterCallback node.properties, node
        matchingNodes.push node
      else
        # or search in children
        for child in node.children
          filterNode child

    # Filter all nodes
    for node in @nodes
      filterNode(node)

    # Push this filter to the chain
    # (Needed when getting all leaves)
    @filterChain.push filterCallback

    # Build up new query so that this one can be re-used
    return new Query(matchingNodes, underscore.clone(@filterChain))

  ##
  # Returns all nodes that match the query.
  # To make this query re-usable, the array is cloned
  resultNodes: =>
    return underscore.clone(@nodes)

  ##
  # Returns all leaves that match the query with the parent properties merged into them.
  # Since a child node might override properties of the parent and vice versa,
  # the whole filters need to be re-applied/re-checked on all leaves.
  # (Thus the initial filtering reduces the number of nodes to be checked, but still requires
  # checking of individual nodes)
  # Returns an array of {node, flattenedProperties} objects
  resultLeaves: (mergeStrategy = 'childWins')=>
    leaves = []

    # Accumulate the leaves of all selected nodes
    for node in @nodes
      nodeLeaves = node.getAllLeaves()
      leaves.push.apply(leaves, nodeLeaves)

    # Flatten properties of all leaves
    for i in [0...leaves.length]
      flattenedProperties = leaves[i].flattenProperties(mergeStrategy)
      leaves[i] = {
        node: leaves[i]
        flattenedProperties: flattenedProperties
      }

    matchingLeaves = []

    # Run all queries on the leaves again to make sure all children match them
    for nodeStruct in leaves
      nodeMatchesFilters = true

      for filter in @filterChain
        # In contrast to default filter, run the callbacks on the flattened properties
        if not filter(nodeStruct.flattenedProperties, nodeStruct.node)
          nodeMatchesFilters = false
          break

      if nodeMatchesFilters
        matchingLeaves.push nodeStruct

    # No need to clone since the array is created in this method
    return matchingLeaves
