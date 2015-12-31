// Require coffeescript and return the main module of fsdb
require('coffee-script').register();

module.exports = {
  FileSystemGraphDatabase: require('./src/FileSystemGraphDatabase'),
  Query: require('./src/Query')
};
