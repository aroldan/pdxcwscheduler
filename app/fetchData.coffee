request = require 'request'
fs = require 'fs'
mkpdf = require 'markdown-pdf'
Handlebars = require 'handlebars'

SOURCE_URL = "https://script.google.com/macros/s/AKfycbwA1pCaqYXfwIMXBtQRkNEaZgTDAYtwHnGrRfZRhp_1AOy8EQ/exec"

# request SOURCE_URL, (error, response, body) ->
#   console.log body

generatePdf = (s) ->
  applyTemplateToMd = (mdString) ->
    console.log mdString
    template = Handlebars.compile mdString
    template s

  opts =
    preProcessMd: applyTemplateToMd

  mkpdf "./templates/schedule.md", opts, (er, pdfPath) ->
    fullName = "#{s.first}_#{s.last}".toLowerCase()

    fs.rename pdfPath, "output/#{fullName}.pdf", ->
      console.log "PDF complete for #{s.first} #{s.last}"

class MDGenerator
  constructor: (json) ->
    @students = JSON.parse json

  generateMd: (test) ->
    generatePdf @students[0]
      
gen = new MDGenerator fs.readFileSync "test.json", "utf-8"
gen.generateMd()