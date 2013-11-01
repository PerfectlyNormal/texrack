require 'sinatra/base'
require 'erb'

module Texrack
  class Endpoint < Sinatra::Base
    enable :logging
    set :public_folder, File.dirname(__FILE__) + '/static'

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
      begin
        @data      = source
        output     = Tempfile.new(["texrack-output", ".png"])
        pdf_source = erb :latex
        pdf = Texrack::LatexToPdf.new(pdf_source, logger).generate_pdf
        png = Texrack::PdfToPng.new(pdf, logger).to_file(output)
        send_file png, {
          disposition: :inline
        }
      rescue Texrack::LatexNotFoundError
        logger.error "Could not find pdflatex in #{ENV['PATH']}"
        send_file File.join(settings.public_folder, "missing-pdflatex.png"), {
          disposition: :inline,
          status: 500
        }
      rescue Texrack::ConvertNotFoundError
        logger.error "Could not find convert (ImageMagick) in #{ENV['PATH']}"
        send_file File.join(settings.public_folder, "missing-convert.png"), {
          disposition: :inline,
          status: 500
        }
      end
    end

    helpers do
      def math_mode?
        params[:math] != "0"
      end

      def root_path
        "#{env['SCRIPT_NAME']}/"
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
