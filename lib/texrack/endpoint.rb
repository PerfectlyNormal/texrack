require 'sinatra/base'
require 'erb'

module Texrack
  class Endpoint < Sinatra::Base
    enable :logging

    get '/' do
      if params[:data].to_s.strip != ""
        render_png(params[:data])
      else
        erb :form
      end
    end

    post '/' do
      render_png(params[:data])
    end

    def render_png(source)
      content_type 'image/png'
      @data      = source
      pdf_source = erb :latex
      pdf = Texrack::LatexToPdf.new(pdf_source, logger).generate_pdf
      tmp = Tempfile.new(["texrack-output", ".png"])
      png = Texrack::PdfToPng.new(pdf).to_file(tmp)
      png
    end

    helpers do
      def math_mode?
        params[:math] != "0"
      end

      def packages
        found = {}
        params[:packages].to_s.split("|").each do |package|
          details = package.match /(?:\[([^\]]+)\])?([A-Za-z]+)/
          found[details[2]] = details[1]
        end
        found
      end
    end
  end
end
