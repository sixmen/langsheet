yaml = require 'js-yaml'
Handlebars = require 'handlebars'
fs = require 'fs'
path = require 'path'

sheet = {}
groups = []
languages = {}

if process.argv.length > 2
  generate_single_item = true
  item = process.argv[2]
  if item.startsWith 'src/'
    item = item.substr 4
  if item.endsWith '.yaml'
    item = item.substr 0, item.length-5
  list = [ {title: item, items: [item]} ]
else
  list = yaml.safeLoad fs.readFileSync 'list.yaml', 'utf-8'
for group in list
  items = []
  groups.push title: group.title, items: items
  for item in group.items
    content = yaml.safeLoad fs.readFileSync "src/#{item}.yaml", 'utf-8'
    key = path.basename item
    items.push key
    sheet[key] = content
    for lang of content
      continue if lang[0] is '_'
      languages[lang] = 1

languages = Object.keys(languages).sort (a, b) ->
  a = a.toLowerCase()
  b = b.toLowerCase()
  if a < b
    return -1
  if a > b
    return 1
  return 0

getSheetContent = (item, language, options) ->
  cell_class = []
  if language is '_title'
    content.body = sheet[item]._title
    content.note = sheet[item]._note
  else
    content = sheet[item][language]
  if not content
    content = body: 'Need to fill'
    cell_class.push 'no_information'
  else if not content.body
    content.body = 'Not applicable\nto this language'
    cell_class.push 'not_applicable'
  if content.note
    cell_class.push 'item_note'
  content.cell_class = cell_class.join ' '
  options.fn content

formatCode = (text, options) ->
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

if generate_single_item
  console.log "<div class='langsheet'>"
  console.log ""
  for language in languages
    getSheetContent groups[0].items[0], language, fn: (content) ->
      body = formatCode(content.body).string
      console.log "<div class='panel panel-info'>"
      console.log "  <div class='panel-heading'>#{language}</div>"
      console.log "  <div class='panel-body'>"
      console.log "    #{body}"
      console.log "  </div>"
      if content.note
        console.log "  <div class='panel-footer'>"
        console.log "    #{content.note}"
        console.log "  </div>"
      console.log "</div>"
      console.log ""
  console.log "</div>"
else
  Handlebars.registerHelper 'getSheetContent', getSheetContent
  Handlebars.registerHelper 'format', formatCode

  template = require './template.handlebars'
  genearated = template languages: languages, table_columns: languages.length+1, groups: groups
  fs.writeFileSync './gen/index.html', genearated, 'utf-8'
