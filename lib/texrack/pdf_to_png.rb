require 'RMagick'

class Texrack::PdfToPng
  def initialize(blob)
    @img = Magick::Image.from_blob(blob) do |info|
      info.density = "300x300"
      info.quality = 90
    end[0]
  end

  def to_file(file)
    @img.write('png:' + file.path)
    file
  end
end
