fs = require 'fs'
path = require 'path'
fm = require 'front-matter'

notSpecialDir = (dir) ->
  dir not in ['slideshow', 'portfolio']

root = path.join(__dirname, '../content')
res = fs.readdirSync(root).filter(notSpecialDir).map((dir) ->
  {attributes} = fm(fs.readFileSync(path.join(root, dir, 'index.md'), 'utf8'))
  return {
    url: "/#{dir}"
    title: attributes.title
  }
)
console.log JSON.stringify([
  {
    url: '/'
    title: 'Home'
  },
  {
    url: '/portfolio'
    title: 'Portfolio'
  }
].concat(res))
