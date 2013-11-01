require 'cocaine'

class Texrack::PdfToPng
  attr_reader :pdf_path, :logger, :line

  def initialize(pdf_path, logger)

    @pdf_path = pdf_path
    @logger   = logger
    @line     = Cocaine::CommandLine.new("convert",
      "-density 300x300 -quality 90 :in :out", logger: logger)
  end

  def to_file(file)
    line.run(in: pdf_path, out: file.path)
    file.path
  end
end
