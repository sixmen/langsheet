require 'js-yaml'
Handlebars = require 'handlebars'
fs = require 'fs'
path = require 'path'

sheet = {}
languages = {}

files = fs.readdirSync 'src'
for file in files
  content = require "./src/#{file}"
  sheet[path.basename file, '.yaml'] = content
  for item of content
    continue if item[0] is '_'
    languages[item] = 1

languages = Object.keys(languages).sort()
items = Object.keys(sheet).sort()

Handlebars.registerHelper 'getSheetContent', (item, language, options) ->
  options.fn sheet[item][language]
Handlebars.registerHelper 'format', (text, options) ->
  text = Handlebars.Utils.escapeExpression text
  text = text.replace /\n/g, '<br>'
  text = text.replace /[ ]/g, '&nbsp;'
  new Handlebars.SafeString text

template = require './template.handlebars'
genearated = template languages: languages, items: items
fs.writeFileSync './gen/index.html', genearated, 'utf-8'
