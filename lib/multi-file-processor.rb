# frozen_string_literal: true

require 'fileutils'

# MultiFileProcessor processes files in a folder moving to the various states inprogress, done or failed.
class MultiFileProcessor
  DEFAULT_INPROGRESS_EXT = 'inprogress'
  DEFAULT_DONE_EXT = 'done'
  DEFAULT_FAILED_EXT = 'failed'

  class FailedException < StandardError; end

  attr_reader :file_pattern,
              :options

  def initialize(file_pattern, options = {})
    @file_pattern = file_pattern
    @options = options
  end

  def each
    while (inprogress_file = next_inprogress_file)
      begin
        yield inprogress_file
        move_inprogress_file_to_done(inprogress_file)
      rescue FailedException
        move_inprogress_file_to_failed(inprogress_file)
      end
    end
  end

  # rubocop:disable Lint/SuppressedException
  def next_inprogress_file
    while (file = next_file)
      begin
        inprogress_file = "#{file}.#{inprogress_ext}"
        FileUtils.mv(file, inprogress_file)
        return inprogress_file
      rescue Errno::ENOENT
      end
    end
  end
  # rubocop:enable Lint/SuppressedException

  def move_inprogress_file_to_done(inprogress_file)
    move_inprogress_file_to_ext(inprogress_file, done_ext)
  end

  def move_inprogress_file_to_failed(inprogress_file)
    move_inprogress_file_to_ext(inprogress_file, failed_ext)
  end

  def reset_files!
    ext_reg = Regexp.new("\\.(#{inprogress_ext}|#{done_ext}|#{failed_ext})$")
    Dir.glob("#{file_pattern}.{#{inprogress_ext},#{done_ext},#{failed_ext}}").each do |file|
      original_file = file.sub(ext_reg, '')
      FileUtils.mv(file, original_file)
    end
  end

  def failed!
    raise FailedException, 'file processing failed'
  end

  def inprogress_ext
    options[:inprogress_ext] || DEFAULT_INPROGRESS_EXT
  end

  def done_ext
    options[:done_ext] || DEFAULT_DONE_EXT
  end

  def failed_ext
    options[:failed_ext] || DEFAULT_FAILED_EXT
  end

  private

  def next_file
    files = Dir.glob(file_pattern)
    return files.sample if options[:sample]

    files.sort! if options[:sort]
    files.first
  end

  def move_inprogress_file_to_ext(inprogress_file, ext)
    new_file = inprogress_file.sub(/#{inprogress_ext}$/, ext)
    FileUtils.mv(inprogress_file, new_file)
  end
end
