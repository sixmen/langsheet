require 'js-yaml'
Handlebars = require 'handlebars'
fs = require 'fs'
path = require 'path'

sheet = {}
groups = []
languages = {}

list = require './list.yaml'
for group in list
  items = []
  groups.push title: group.title, items: items
  for item in group.items
    content = require "./src/#{item}.yaml"
    key = path.basename item
    items.push key
    sheet[key] = content
    for lang of content
      continue if lang[0] is '_'
      languages[lang] = 1

languages = Object.keys(languages).sort()

Handlebars.registerHelper 'getSheetContent', (item, language, options) ->
  content = sheet[item][language]
  if not content
    content = cell_class: 'no_information'
  else if not content.body
    content.cell_class = 'not_applicable'
  options.fn content
Handlebars.registerHelper 'format', (text, options) ->
  result = ''
  in_command = false
  command = ''
  for ch in text or ''
    if in_command
      if /\w+/.test ch
        command += ch
      else
        if ch is '{'
          result += "<span class='cmd_#{command}'>"
        else if ch is '}'
          result += '</span>'
        else if ch is '\\'
          result += '\\'
        in_command = false
    else
      if ch is '\\'
        in_command = true
        command = ''
      else if ch is '\n'
        result += '<br>'
      else if ch is ' '
        result += '&nbsp;'
      else if ch is '&'
        result += '&amp;'
      else if ch is '<'
        result += '&lt;'
      else if ch is '>'
        result += '&gt;'
      else
        result += ch
  new Handlebars.SafeString result

template = require './template.handlebars'
genearated = template languages: languages, table_columns: languages.length+1, groups: groups
fs.writeFileSync './gen/index.html', genearated, 'utf-8'
