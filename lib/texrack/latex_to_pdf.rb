class Texrack::LatexToPdf
  def self.config
    @config ||= {command: 'pdflatex', arguments: [], parse_twice: false}
  end

  attr_reader :config, :latex, :logger

  def initialize(latex, logger=Logger.new(STDOUT), overrides = {})
    @latex  = latex
    @logger = logger
    @config = self.class.config.merge(overrides)
  end

  # Converts a string of LaTeX code into a binary string of PDF.
  #
  # pdflatex is used to convert the file.
  def generate_pdf
    raise Texrack::LatexNotFoundError unless has_pdflatex?

    logger.debug "Generating PDF from #{latex}"
    input = Tempfile.new(["texrack-input", ".tex"])
    input.binmode
    input.write(latex)
    input.flush

    Process.waitpid(
      fork do
        begin
          Dir.chdir File.dirname(input)
          args = config[:arguments] + %w[-shell-escape -interaction batchmode -halt-on-error] + [input.path]

          if config[:parse_twice]
            logger.debug("Texrack executing (parse twice): #{config[:command]} -draftmode #{args}")
            system config[:command], '-draftmode', *args
          end

          logger.debug "Texrack executing: #{config[:command]} #{args}"
          exec config[:command], *args
        rescue
          logger.error "#{$!.message}:\n#{$!.backtrace.join("\n")}\n"
        ensure
          Process.exit! 1
        end
      end)

    output = input.path.sub(/\.tex$/, '.pdf')
    if File.exist?(output)
      result = File.read(output)
    else
      logger.warn "Unable to find file #{output}"
      raise "pdflatex failed"
    end

    input.close
    result
  end

  def has_pdflatex?
    ENV["PATH"].split(':').any? {|x| FileTest.executable? "#{x}/pdflatex" }
  end
  private :has_pdflatex?
end
