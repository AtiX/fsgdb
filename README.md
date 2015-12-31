# fsgdb - File System Graph Database
![Travis CI Status](https://travis-ci.org/AtiX/fsgdb.svg)

fsgdb is a graph like database based on the file system. Based on a root
folder (or node), you can create subfolders/subnodes and attach data to each
node by creating paresable files in each directory.

By allowing to merge data from parent nodes (think of: having a "blog" folder/node which 
contains metadata about your blog, which is then merged with each blog-entry-folder/sub-node),
you can store data efficiently and deduplicated while maintaining a clear folder structure
that is easily editable with standard editors.

## Supported Parsers

At the moment, the following parsers are supported:

 - **markdown**: Parses markdown (```*.md```) files and attaches the parsed HTML content to each ```node.markdown.<filename> = "<parsedMarkdown>"```
 - **yaml**: Parses yaml (```*.yml```) files and attaches the parsed properties to each ```node.<filename> = { <parsedProperties> }```,
 with the exception that the properties of the file ```metadata.yml``` are added directly to the node without the in-between ```<filename>``` object.
