Parser = require './Parser'
marked = require 'marked'
fs = require 'fs'
path = require 'path'

ExifImage = require('exif').ExifImage
gm = require 'gm'

##
# Parses images and tries to load metadata information from them.
# Adds helper method to access the image content directly
# Constructor options and defaults:
# createThumbnails: false
# thumbnailSize: 400
# thumbnailQuality: 70
module.exports = class ImageParser extends Parser

  ##
  # As for now, only parse jpg images
  doesParse: (filename) ->
    if not Parser.hasExtension filename, ['jpg']
      return false

    # Don't re-parse auto generated thumbnails
    if filename.indexOf('.thumbnail.jpg', filename.length - 14) != -1
      return false

    return true

  ##
  # Parses the image (exif information) and adds functions to actually load the file content
  parse: (filename, dirNode) =>
    return new Promise (resolve, reject) =>
      # build up the entry
      imageEntry = {}

      # Determine key name
      imageEntry.name = path.basename filename, '.jpg'
      imageEntry.fileName = filename

      # Load exif information
      p = @loadExifData(filename)
      p = p.then (exifData) ->
        imageEntry.exifData = exifData

      # If desired by the user, create a thumbnail
      if @options.createThumbnails
        p = p.then =>
          @createThumbnail filename, imageEntry

      # Attach functions to return the image content
      imageEntry.getImageData = () => return @returnImageData(filename)

      # Attach to node
      if not dirNode.hasProperty 'images'
        dirNode.setProperty 'images', {}

      images = dirNode.getProperty 'images'
      images[imageEntry.name] = imageEntry

      resolve(p)

  loadExifData: (filename) ->
    return new Promise (resolve, reject) ->
      try
        new ExifImage {image: filename}, (error, exifData) ->
          if error != false
            reject(error)
            return
          resolve(exifData)
      catch error
        reject(error)
        return

  createThumbnail: (filename, imageEntry) =>
    return new Promise (resolve, reject) =>
      thumbnailSize = @options.thumbnailSize or 300
      thumbnailQuality = @options.thumbnailQuality or 70

      thumbnailFilename = filename + '.thumbnail.jpg'

      gm(filename)
      .resize(thumbnailSize, thumbnailSize)
      .noProfile()
      .quality(thumbnailQuality)
      .compress('JPEG')
      .write thumbnailFilename, (err) =>
        if err?
          reject(err)
          return

        imageEntry.thumbnail = {
          filename: thumbnailFilename
          getImageData: () => return @returnImageData(thumbnailFilename)
        }
        resolve()

  ##
  # Load and cache image data
  # returns a promise
  returnImageData: (imageName) =>
    @imageDataCache ?= {}

    if @imageDataCache[imageName]?
     return Promise.resolve(@imageDataCache[imageName])

    return new Promise (resolve, reject) =>
      fs.readFile imageName, (error, data) =>
        if error?
          reject(error)
          return

        @imageDataCache[imageName] = data
        resolve(data)






