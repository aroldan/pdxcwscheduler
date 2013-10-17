request = require 'request'
fs = require 'fs'
mkpdf = require 'markdown-pdf'
Handlebars = require 'handlebars'
Q = require 'q'

SOURCE_URL = "https://script.google.com/macros/s/AKfycbwA1pCaqYXfwIMXBtQRkNEaZgTDAYtwHnGrRfZRhp_1AOy8EQ/exec"

generatePdf = (s) ->
  deferred = Q.defer()

  applyTemplateToMd = (mdString) ->
    template = Handlebars.compile mdString
    template s

  opts =
    preProcessMd: applyTemplateToMd

  mkpdf "./templates/schedule.md", opts, (er, pdfPath) ->
    fullName = "#{s.first}_#{s.last}".toLowerCase()
    outpath = "output/#{fullName}.pdf"

    fs.rename pdfPath, outpath, ->
      console.log "PDF complete for #{s.first} #{s.last}"
      deferred.resolve(outpath)

  deferred.promise

class MDGenerator
  constructor: (json) ->
    @students = JSON.parse json

  generatePdfForStudent: (s) ->
    return -> generatePdf s

  generateMds: ->
    tasks = (@generatePdfForStudent(s) for s in @students)
    tasks.reduce(Q.when, Q())
      
gen = new MDGenerator fs.readFileSync "test.json", "utf-8"
gen.generateMds()