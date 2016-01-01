# This sample application demos some functionality of the fsgdb

# 1.) Initialize the Database from a directory, register all parsers and load all files.
FileSystemGraphDatabase = require '../src/FileSystemGraphDatabase'
graph = new FileSystemGraphDatabase({ path: './sampleApp/sampleData'})
graph.registerParser('MarkdownParser')
graph.registerParser('YamlParser')
graph.registerParser('ImageParser', {createThumbnails: true})
graphPromise = graph.load()

# 2.) After having loaded everything, print the graph to stdout
graphPromise = graphPromise.then (rootNode) ->
  console.log 'All nodes as a tree:'
  console.log ''
  printTree 0, rootNode

  console.log ''
  console.log 'All nodes as merged objects:'
  console.log ''

  leaves = rootNode.getAllLeaves()
  documents = leaves.map (node) -> node.flattenProperties()

  for doc in documents
    console.log JSON.stringify(doc)
    console.log ''

  return rootNode

# Print the created tree somehow nicely
printTree = (indentation, node) ->
  printIndentated indentation, '--( ) Node:'

  node.forEachProperty (key, value) ->
    if 'object' != typeof value
      valueStr = value.toString()
    else
      valueStr = JSON.stringify(value)

    if valueStr.length > 50
      valueStr = valueStr.substring(0,50)
      valueStr += '...'

    printIndentated indentation, "   |  #{key}: #{valueStr}"

  printIndentated indentation, '   |'

  indentation++
  for child in node.children
    printTree indentation, child

printIndentated = (num, string) ->
  str = getSpaces(num)
  str += string
  console.log str

getSpaces = (num) ->
  str = ''
  for i in [0..num]
    str += '   |'
  return str

# 3.) Then, execute some queries
graphPromise = graphPromise.then (rootNode) ->
  console.log "Executing queries:"

  Query = require '../src/Query'

  q = new Query(rootNode)

  # we could use q.filter(callback) for arbitrary queries, but use helper functions here
  rootTagFilter = q.whereContains('tags', 'rootTag')
  tagAFilter = rootTagFilter.whereContains('tags', 'a')
  mdFilter = q.withProperty('markdown')

  leaves = rootTagFilter.resultLeaves()
  console.log "When merging properties, there are #{leaves.length} nodes that have the 'rootTag' tag"

  leaves = tagAFilter.resultLeaves()
  console.log "When merging properties, there are #{leaves.length} nodes that have both the 'rootTag' and 'a' tags"

  leaves = mdFilter.resultLeaves()
  console.log "When merging properties, there are #{leaves.length} nodes that have a 'markdown' property"

# 4.) Catch errors
graphPromise.catch (error) ->
  console.error "Got an error:"
  console.error error
