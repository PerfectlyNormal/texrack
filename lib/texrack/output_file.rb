require 'fileutils'

class Texrack::OutputFile
  def initialize(digest)
    @digest = digest
    FileUtils.mkdir_p file_path
  end

  def path
    file
  end
  alias_method :to_path, :path

  def exists?
    File.readable?(file) && File.size?(file)
  end

  def finish
    FileUtils.chmod(0644, file)
  end

  private

  attr_reader :digest

  def file
    File.join(file_path, "#{digest}.png")
  end

  def file_path
    File.join(cache_dir, *partition)
  end

  def cache_dir
    Texrack.config[:cache_dir]
  end

  def partition
    digest.scan(/.{3}/).first(3)
  end
end