require 'texrack/version'
require 'texrack/latex_to_pdf'
require 'texrack/pdf_to_png'
require 'texrack/endpoint'

module Texrack
  class LatexNotFoundError < StandardError; end
  class ConvertNotFoundError < StandardError; end
  class LatexFailedError < StandardError; end

  def self.config
    @config ||= {
      pdflatex: "pdflatex",
      convert:  "convert",
      logger:   nil
    }
  end
end
