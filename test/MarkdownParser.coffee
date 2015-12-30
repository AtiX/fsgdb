chai = require 'chai'
expect = chai.expect
path = require 'path'

testUtilities = require './testUtilities'

MarkdownParser = require '../src/parser/MarkdownParser.coffee'
TreeNode = require '../src/TreeNode.coffee'

testPath = undefined

describe 'MarkdownParser', ->
  #  Create an empty directory to test in
  beforeEach (done) ->
    testUtilities.createTempDirectory (dirName) ->
      testPath = dirName
      done()

  # Delete temporary directory and all its contents
  afterEach (done) ->
    testUtilities.deleteTempDirectory(testPath, done)

  it 'should only parse .md files', ->
    parser = new MarkdownParser()

    expect(parser.doesParse('myFile.md')).to.be.true
    expect(parser.doesParse('myFile.dot.md')).to.be.true
    expect(parser.doesParse('myFile.txt')).to.be.false
    expect(parser.doesParse('myFile')).to.be.false

  it 'should attach parsed markdown to a node', (done) ->
    testUtilities.writeFile(testPath, 'test.md', '# Header\n\nParagraph\n')
    .then ->
      node = new TreeNode()
      parser = new MarkdownParser()

      parser.parse(path.join(testPath, 'test.md'), node)
      .then ->
        expect(node.hasProperty('markdown')).to.be.true
        
        mdproperty = node.getProperty 'markdown'
        expect(mdproperty.test).to.not.be.null
        expect(mdproperty.test).to.equal(
          '<h1 id="header">Header</h1>\n<p>Paragraph</p>\n'
        )
        done()
      .catch (error) -> done(error)
    .catch (error) -> done(error)
