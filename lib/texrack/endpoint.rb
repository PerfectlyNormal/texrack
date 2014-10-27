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

    get '/crossdomain.xml' do
      content_type 'application/xml'
      erb :crossdomain
    end

    def render_png
      begin
        output = Texrack::OutputFile.new(digest)
        unless output.exists?
          pdf_source = erb :latex
          pdf = Texrack::LatexToPdf.new(pdf_source, logger).generate_pdf
          Texrack::PdfToPng.new(pdf, trim?, logger).to_file(output)
          output.finish
        end

        set_headers
        send_file output, disposition: :inline
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
        send_file File.join(settings.public_folder, filename), {
        headers['ETag'] = ''
          disposition: :inline,
          status: error_status
        }
      end

      def set_headers
        content_type 'image/png'
        etag digest
        cache_control :public, max_age: 60 * 60 * 24 * 365
        expires 60 * 60 * 24 * 365
      end

      def math_mode?
        params[:math] != "0"
      end

      def trim?
        params[:trim] == "1"
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
        @digest ||= Digest::SHA1.hexdigest("#{Texrack::VERSION}:#{data}:#{math_mode?}:#{trim?}:#{packages_source}")
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
