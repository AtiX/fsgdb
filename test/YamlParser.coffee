chai = require 'chai'
expect = chai.expect
path = require 'path'

testUtilities = require './testUtilities'

YamlParser = require '../src/parser/YamlParser.coffee'
TreeNode = require '../src/TreeNode.coffee'

testPath = undefined

describe 'YamlParser', ->
  # Create an empty directory to test in
  beforeEach (done) ->
    testUtilities.createTempDirectory (dirName) ->
      testPath = dirName
      done()

  # Delete temporary directory and all its contents
  afterEach (done) ->
    testUtilities.deleteTempDirectory(testPath, done)

  it 'should only parse .yml files', ->
    parser = new YamlParser()

    expect(parser.doesParse('myFile.yml')).to.be.true
    expect(parser.doesParse('myFile.dot.yml')).to.be.true
    expect(parser.doesParse('myFile.yaml')).to.be.false
    expect(parser.doesParse('myFile')).to.be.false

  it 'should attach parsed yaml to a node', (done) ->
    testUtilities.writeFile(testPath, 'yamlData.yml', 'a: b\n\n')
    .then ->
      node = new TreeNode()
      parser = new YamlParser()

      parser.parse(path.join(testPath, 'yamlData.yml'), node)
      .then ->
        expect(node.hasProperty('yamlData')).to.be.true

        yamlData = node.getProperty 'yamlData'
        expect(yamlData).to.eql({a: 'b'})
        done()
      .catch (error) -> done(error)
    .catch (error) -> done(error)

  it 'should attach parsed metadata.yml sub-objects directly to a node', (done) ->
    testUtilities.writeFile(testPath, 'metadata.yml', 'ma: b\n\nmb: c\n\n')
    .then ->
      node = new TreeNode()
      parser = new YamlParser()

      parser.parse(path.join(testPath, 'metadata.yml'), node)
      .then ->
        expect(node.hasProperty('ma')).to.be.true
        expect(node.hasProperty('mb')).to.be.true

        ma = node.getProperty 'ma'
        expect(ma).to.eql('b')

        ma = node.getProperty 'mb'
        expect(ma).to.eql('c')

        done()
      .catch (error) -> done(error)
    .catch (error) -> done(error)
