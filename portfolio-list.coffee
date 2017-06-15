fs = require 'fs'
path = require 'path'
fm = require 'front-matter'

notIndex = (file) -> file isnt 'index.md'

root = path.join(__dirname, '../content/portfolio')
res = fs.readdirSync(root).filter(notIndex).map((dir) ->
  contents = fs.readdirSync(path.join(root, dir)).filter(notIndex)
  {attributes} = fm(fs.readFileSync(path.join(root, dir, 'index.md'), 'utf8'))
  return {
    name: dir
    category: attributes.category
    images: contents
  }
)
console.log JSON.stringify res
