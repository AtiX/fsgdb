// Require coffeescript and return the main module of fsdb
require('coffee-script').register()
module.exports = require('./src/FileSystemGraphDatabase');
