require 'sinatra/base'
require 'erb'
require 'digest/sha1'

module Texrack
  class Endpoint < Sinatra::Base
    enable :logging
    set :root,          File.expand_path(File.dirname(__FILE__) + "/../../web")
    set :public_folder, Proc.new { "#{root}/assets" }
    set :views,         Proc.new { "#{root}/views" }

    get '/' do
      if data != ''
        render_png
      else
        erb :form
      end
    end

    post '/' do
      render_png
    end

    def render_png
      content_type 'image/png'
      etag digest
      cache_control :public, max_age: 60 * 60 * 24 * 365
      expires 60 * 60 * 24 * 365

      begin
        output     = Texrack::OutputFile.new(digest)
        if output.exists?
          send_file output, disposition: :inline
        else
          pdf_source = erb :latex
          pdf = Texrack::LatexToPdf.new(pdf_source, logger).generate_pdf
          png = Texrack::PdfToPng.new(pdf, logger).to_file(output)
          output.finish
          send_file png, disposition: :inline
        end
      rescue Texrack::LatexFailedError
        send_static_error "latex-failed.png"
      rescue Texrack::LatexNotFoundError
        logger.error "Could not find pdflatex in #{ENV['PATH']}"
        send_static_error "missing-pdflatex.png"
      rescue Texrack::ConvertNotFoundError
        logger.error "Could not find convert (ImageMagick) in #{ENV['PATH']}"
        send_static_error "missing-convert.png"
      end
    end

    helpers do
      def logger
        @logger ||= (Texrack.config[:logger] || Logger.new(STDERR))
      end

      def send_static_error(filename)
        headers['ETag'] = nil
        send_file File.join(settings.public_folder, filename), {
          disposition: :inline,
          status: error_status
        }
      end

      def math_mode?
        params[:math] != "0"
      end

      def always_respond_with_200?
        params[:always_200] == "1"
      end

      def error_status
        always_respond_with_200? ? 200 : 500
      end

      def root_path
        "#{env['SCRIPT_NAME']}/"
      end

      def data
        params[:data].to_s.strip
      end

      def digest
        @digest ||= Digest::SHA1.hexdigest("#{data}:#{math_mode?}:#{packages_source}")
      end

      def packages_source
        params[:packages].to_s.strip
      end

      def packages
        found = {}
        packages_source.split("|").each do |package|
          details = package.match /(?:\[([^\]]+)\])?([A-Za-z]+)/
          found[details[2]] = details[1]
        end
        found
      end
    end
  end
end
