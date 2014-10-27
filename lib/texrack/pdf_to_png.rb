require 'cocaine'

class Texrack::PdfToPng
  attr_reader :pdf_path, :logger, :line

  def initialize(pdf_path, trim, logger)
    @pdf_path = pdf_path
    @trim     = trim
    @logger   = logger
    @line     = Cocaine::CommandLine.new(command,
      "-density 300x300 -quality 90 #{"-trim" if trim} :in :out", logger: logger)
  end

  def command
    Texrack.config[:convert] || "convert"
  end

  def to_file(file)
    line.run(in: pdf_path, out: file.path)
    file.path
  rescue Cocaine::CommandNotFoundError => e
    raise Texrack::ConvertNotFoundError
  end
end
