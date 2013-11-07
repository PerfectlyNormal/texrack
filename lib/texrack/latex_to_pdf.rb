class Texrack::LatexToPdf
  attr_reader :latex, :logger

  def initialize(latex, logger=Logger.new(STDOUT))
    @latex  = latex
    @logger = logger
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
          args = %w[-shell-escape -interaction batchmode -halt-on-error] + [input.path]

          logger.debug "Texrack executing: #{command} #{args}"
          exec command, *args
        rescue
          logger.error "#{$!.message}:\n#{$!.backtrace.join("\n")}\n"
        ensure
          Process.exit! 1
        end
      end)

    output  = input.path.sub(/\.tex$/, '.pdf')
    logfile = input.path.sub(/\.tex$/, '.log')
    if !File.exist?(output)
      loglines = File.read(logfile)
      logger.error "Unable to find file #{output}"
      logger.error "LaTeX output: #{loglines}"
      raise Texrack::LatexFailedError
    end

    input.close
    output
  end

  def command
    Texrack.config[:pdflatex] || "pdflatex"
  end

  def has_pdflatex?
    return true if File.exists?(command) && FileText.executable?(command)
    ENV["PATH"].split(':').any? {|x| FileTest.executable? "#{x}/pdflatex" }
  end
  private :has_pdflatex?
end
