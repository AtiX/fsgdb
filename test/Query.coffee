chai = require 'chai'
expect = chai.expect
path = require 'path'
fs = require 'fs'

Query = require '../src/Query.coffee'
TreeNode = require '../src/TreeNode.coffee'

describe 'Query', ->

  it 'should accept a single node or an array of nodes in constructor', ->
    node = {}

    q = new Query(node)
    expect(q.nodes.length).to.equal(1)
    expect(q.nodes[0]).to.equals(node)

    nodeArray = [node]
    q = new Query(nodeArray)
    expect(q.nodes).to.equal(nodeArray)

  it 'should filter nodes based on a filter callback', ->
    q = basicQuery()

    # Expect the correct filter result
    expect(q.nodes.length).to.eql(2)
    expect(q.nodes[0].uid).to.eql(0)
    expect(q.nodes[1].uid).to.eql(4)

  it 'should maintain a correct filter chain', ->
    q = new Query([])

    cb1 = -> return true
    cb2 = -> return true

    q1 = q.filter(cb1).filter(cb2)

    expect(q.filterChain.length).to.equal(0)
    expect(q1.filterChain.length).to.equal(2)
    expect(q1.filterChain[0]).to.equal(cb1)
    expect(q1.filterChain[1]).to.equal(cb2)

  it 'should return resultNodes correctly', ->
    q = basicQuery()
    nodes = q.resultNodes()

    # Expect correct values
    expect(nodes.length).to.equal(2)
    expect(nodes[0].uid).to.equal(0)
    expect(nodes[1].uid).to.equal(4)

  it 'should return resultNodes as cloned array', ->
    q = basicQuery()
    nodes = q.resultNodes()

    expect(nodes != q.nodes)

  it 'should return resultLeaves (strategy: "childWins") correctly', ->
    q = basicQuery()
    nodeStructs = q.resultLeaves('childWins')

    expect(nodeStructs.length).to.equal(2)
    expect(nodeStructs[0].node.uid).to.equal(2)
    expect(nodeStructs[1].node.uid).to.equal(4)

  it 'should return resultLeaves (strategy: "parentWins") correctly', ->
    q = basicQuery()
    nodeStructs = q.resultLeaves('parentWins')

    expect(nodeStructs.length).to.equal(2)
    expect(nodeStructs[0].node.uid).to.equal(2)
    expect(nodeStructs[1].node.uid).to.equal(3)

  it 'should filter with whereContains correctly', ->
    node0 = { properties: { tags: ['a', 'b'] }, children: [], uid: 0 }
    node1 = { properties: { tags: ['a', 'c'], basicProperty: 'basicValue' }, children: [], uid: 1 }
    node2 = { properties: { tags: ['d', 'e'], object: { objKey: true } }, children: [], uid: 2 }

    q = new Query([node0,node1,node2])

    # Containment in arrays
    expect(q.whereContains('tags','a').resultNodes().length).to.equal(2)
    expect(q.whereContains('tags','a').resultNodes()[0].uid).to.equal(0)
    expect(q.whereContains('tags','a').resultNodes()[1].uid).to.equal(1)

    expect(q.whereContains('tags','e').resultNodes().length).to.equal(1)
    expect(q.whereContains('tags','e').resultNodes()[0].uid).to.equal(2)

    expect(q.whereContains('tags','a').whereContains('tags','c').resultNodes().length).to.equal(1)
    expect(q.whereContains('tags','a').whereContains('tags','c').resultNodes()[0].uid).to.equal(1)

    # Keys in objects
    expect(q.whereContains('object', 'objKey').resultNodes().length).to.equal(1)
    expect(q.whereContains('object', 'objKey').resultNodes()[0].uid).to.equal(2)

    # Equality check as fallback for simple objects
    expect(q.whereContains('basicProperty', 'basicValue').resultNodes().length).to.equal(1)
    expect(q.whereContains('basicProperty', 'basicValue').resultNodes()[0].uid).to.equal(1)

  it 'should filter with withProperty correctly', ->
    node0 = { properties: { a: 'va' }, children: [], uid: 0 }
    node1 = { properties: { a: 'va2', b: 'vb' }, children: [], uid: 1 }

    q = new Query([node0, node1])

    expect(q.withProperty('a').resultNodes().length).to.eql(2)
    expect(q.withProperty('a').resultNodes()[0].uid).to.eql(0)
    expect(q.withProperty('a').resultNodes()[1].uid).to.eql(1)

    expect(q.withProperty('a', 'va').resultNodes().length).to.eql(1)
    expect(q.withProperty('a', 'va').resultNodes()[0].uid).to.eql(0)

    expect(q.withProperty('b').resultNodes().length).to.eql(1)
    expect(q.withProperty('b').resultNodes()[0].uid).to.eql(1)

# Helper function with a basic query that can be re-used
basicQuery = ->
  r0 = new TreeNode()
  r0.uid = 0
  r0.setProperty 'a', true
  r1 = new TreeNode()
  r1.uid = 1
  r1.setProperty 'a', false

  c01 = r0.addNewChild()
  c01.uid = 2
  c01.setProperty 'a', true
  c02 = r0.addNewChild()
  c02.uid = 3
  c02.setProperty 'a', false

  c11 = r1.addNewChild()
  c11.uid = 4
  c11.setProperty 'a', true
  c12 = r1.addNewChild()
  c12.uid = 5
  c12.setProperty 'a', false

  q = new Query([r0, r1])

  q = q.filter (nodeProperties, node) -> return nodeProperties.a
  return q
