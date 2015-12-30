chai = require 'chai'
expect = chai.expect
path = require 'path'
fs = require 'fs'

testUtilities = require './testUtilities'

FileTreeWalker = require '../src/FileTreeWalker.coffee'
TreeNode = require '../src/TreeNode.coffee'

testPath = undefined

describe 'FileTreeWalker', ->
  
  #  Create an empty directory to test in
  beforeEach (done) ->
    testUtilities.createTempDirectory (dirName) ->
      testPath = dirName
      done()

  # Delete temporary directory and all its contents
  afterEach (done) ->
    testUtilities.deleteTempDirectory(testPath, done)

  it 'should list files and directories in a folder', (done) ->
    # Prepare directory structure
    p = Promise.all([
      testUtilities.makeSubDir(testPath, 'subA'),
      testUtilities.makeSubDir(testPath, 'subB'),
      testUtilities.touchFile(testPath, 'fileA'),
      testUtilities.touchFile(testPath, 'fileB')
    ])

    p = p.then ->
      walker = new FileTreeWalker([],testPath)

      walkPromise = walker.listFolder(testPath)
      walkPromise = walkPromise.then (result) ->
        expect(result.files.length).to.equal(2)
        expect(result.subdirs.length).to.equal(2)
        expect(result.files.indexOf('fileA') >= 0).to.be.true
        expect(result.files.indexOf('fileB') >= 0).to.be.true
        expect(result.subdirs.indexOf('subA') >= 0).to.be.true
        expect(result.subdirs.indexOf('subB') >= 0).to.be.true
        done()
      walkPromise = walkPromise.catch (error) -> done(error)
      return walkPromise

    p.catch (error) -> done(error)

  it 'should parse a file by calling a parser', (done) ->
    dirNode = {}

    parserWasCalled = false
    mockParser = {}
    mockParser.doesParse = (fileName) ->
      return true
    mockParser.parse = (fileName, dirNode) ->
      expect(fileName).to.equal(path.join('pathName', 'fileName'))
      expect(dirNode).to.equal(dirNode)
      parserWasCalled = true
      return Promise.resolve()

    walker = new FileTreeWalker([mockParser],testPath)
    walker.parseFile('pathName', 'fileName', dirNode)
    .then ->
      expect(parserWasCalled).to.be.true
      done()
    .catch (error) -> done(error)

  it 'should parse a folder structure', (done) ->
    mockParser = {}
    mockParser.timesCalled = 0
    mockParser.doesParse = -> return true
    mockParser.parse = ->
      mockParser.timesCalled++
      return Promise.resolve()

    mockListFolder = (dir) ->
      if dir == path.normalize('/root')
        return Promise.resolve({
          dir: dir
          subdirs: ['subA']
          files: ['rootA', 'rootB']
        })
      else if dir == path.join('/root', 'subA')
        return Promise.resolve({
          dir: dir
          subdirs: []
          files: ['subfileA']
        })

    walker = new FileTreeWalker([mockParser],testPath)
    walker.listFolder = mockListFolder

    node = new TreeNode()

    walker.parseFolder(path.normalize('/root'), node)
    .then ->
      expect(mockParser.timesCalled).to.eql(3)

      expect(node.children.length).to.eql(1)
      child = node.children[0]

      expect(node.getProperty('dirName')).to.equal('root')
      expect(node.getProperty('fullPath')).to.equal(path.normalize('/root'))
      expect(child.getProperty('dirName')).to.equal('subA')
      expect(child.getProperty('fullPath')).to.equal(
        path.normalize('/root/subA')
      )

      done()
    .catch (error) -> done(error)
