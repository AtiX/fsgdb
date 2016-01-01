chai = require 'chai'
expect = chai.expect
path = require 'path'
fs = require 'fs'

testUtilities = require './testUtilities'

ImageParser = require '../src/parser/ImageParser.coffee'
TreeNode = require '../src/TreeNode.coffee'

testPath = undefined

describe 'ImageParser', ->
  # Create an empty directory to test in
  beforeEach (done) ->
    testUtilities.createTempDirectory (dirName) ->
      testPath = dirName
      done()

  # Delete temporary directory and all its contents
  afterEach (done) ->
    testUtilities.deleteTempDirectory(testPath, done)

  it 'should only parse .jpg files', ->
    parser = new ImageParser()

    expect(parser.doesParse('myFile.png')).to.be.false
    expect(parser.doesParse('myFile.jpg')).to.be.true

  it 'should attach image metadata and helper functions', (done) ->
    # Copy test image
    fs.createReadStream('./test/ImageParserTest.jpg').pipe(fs.createWriteStream(path.join(testPath ,'testImage.jpg')));

    node = new TreeNode()
    parser = new ImageParser()

    parser.parse(path.join(testPath, 'testImage.jpg'), node)
    .then ->
      # Expect an image property with the testImage key and exif data
      expect(node.hasProperty('images')).to.be.true
      imageProperty = node.getProperty 'images'

      image = imageProperty.testImage
      expect(image).not.to.be.null
      expect(image.exifData).not.to.be.null

      # Expect Actual data when requesting it
      image.getImageData()
      .then (imageData) ->
        expect(imageData.length).to.eql(9371)
        done()
      .catch (error) -> done (error)
    .catch (error) -> done(error)

