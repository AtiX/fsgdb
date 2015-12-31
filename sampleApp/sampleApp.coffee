# For now, only a test script that logs the created graph to the console

FileSystemGraphDatabase = require '../src/FileSystemGraphDatabase'

graph = new FileSystemGraphDatabase({ path: './sampleApp/sampleData'})
graph.registerParser('MarkdownParser')
graph.registerParser('YamlParser')
graph.load()
.then (rootNode) ->
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
