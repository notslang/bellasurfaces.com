fs = require 'fs'
path = require 'path'

notIndex = (file) ->
  file isnt 'index.md' and file isnt 'index.html'

root = path.join(__dirname, '../content/portfolio')
res = fs.readdirSync(root).filter(notIndex).map((dir) ->
  contents = fs.readdirSync(path.join(root, dir)).filter(notIndex)
  return {
    name: dir
    images: contents
  }
)
console.log JSON.stringify res
