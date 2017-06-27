fm = require 'front-matter'
marked = require 'marked'
{ArgumentParser} = require 'argparse'
findIndex = require 'lodash.findindex'

argparser = new ArgumentParser(
  addHelp: true
)
argparser.addArgument(
  ['pageName']
  nargs: '?'
  defaultValue: ''
  help: ''
  type: 'string'
  metavar: 'PAGE_NAME'
)
argparser.addArgument(
  ['viewName']
  nargs: '?'
  defaultValue: ''
  help: ''
  type: 'string'
  metavar: 'VIEW_NAME'
)

description = 'Bella Surfaces has over 20 years of combined experience in
installing custom surfaces in Kitchens, Bathrooms, Playrooms and Commercial
facilities'

argv = argparser.parseArgs()
pagePath = argv.pageName.replace(
  /^content/, ''
).replace(
  /index\.md$/, ''
)
if pagePath isnt '/' then pagePath = pagePath.replace(/\/$/, '')

view = require "./view/#{argv.viewName}.marko.js"
console.error argv.viewName, pagePath

prepareMarkdown = (str) ->
  extracted = fm(str)
  obj = extracted.attributes
  obj.url = pagePath
  obj.pageList = require './page-list.json'
  if argv.viewName in ['index', 'portfolio/index', 'portfolio/entry']
    obj.portfolioList = require './portfolio-list.json'
    obj.portfolioListIndex = findIndex(
      obj.portfolioList
      name: pagePath.split('/')[2]
    )
  obj.contents = marked(extracted.body)
  console.warn obj
  return obj

preparePortfolioIndex = ->
  {
    portfolioList: require './portfolio-list.json'
    pageList: require './page-list.json'
  }

render = (obj) ->
  obj.googleAnalyticsId = 'UA-32157718-1'
  obj.phoneNumber = '978-667-2400'
  obj.description = description
  view.stream(
    obj
  ).pipe(
    process.stdout
  )

process.stdin.setEncoding 'utf8'
process.stdin.on 'readable', ->
  buffer = ''
  while (chunk = process.stdin.read()) isnt null
    buffer += chunk
  if buffer isnt ''
    render(
      if argv.viewName in ['index', 'portfolio/index']
        preparePortfolioIndex()
      else
        prepareMarkdown(buffer)
    )
  return
