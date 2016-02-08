#!/usr/bin/env ruby 
require 'charlock_holmes'
class SubtitleEncodingFixer
  @@files=[]
  attr_accessor :subtitle_source
  def initialize args
    @subtitle_source=args[:subtitle_source]
    fetch_source
  end
  def convert_to_utf8
    if @@files.length > 0
      @@files.each {|file| convert_srt_file_to_utf8 file }
    else
      puts "no file to convert it"
    end
  end
  private
  def convert_srt_file_to_utf8 sub_file
    if (is_writable? sub_file) && (!any_text? sub_file)
      content=""
      File.open(sub_file,"r") {|file| content = file.read }
      detection = CharlockHolmes::EncodingDetector.detect(content)
      if detection[:encoding] != "UTF-8"
        File.delete(sub_file)
        File.open(sub_file,"w") { |file| file.write(CharlockHolmes::Converter.convert content, detection[:encoding], 'UTF-8')}
      end
   else
      puts "this file : #{sub_file} is unwritable or has no text"
    end
  end
  def fetch_source
    if dir_exist? subtitle_source
      @@files=get_srt_file_of_dir subtitle_source
    elsif exist? subtitle_source
      if supported? subtitle_source
        @@files[0]=subtitle_source
      end
    else
      puts "#{source} is not a file or directory"
    end
  end
  def get_srt_file_of_dir dir
    full_dir_path=File.absolute_path(dir)
    Dir.glob("#{full_dir_path}/*.srt").each {|file| File.absolute_path(file,full_dir_path)}
  end

  def is_writable? file
    File.writable?(file)
  end
  def any_text? file
    File.zero?(file)
  end
  def exist? file_name
    !file_name.nil? && File.exist?(file_name)
  end
  def dir_exist? directory_name
    !directory_name.nil? && Dir.exist?(directory_name)
  end
  def supported? file_name
    true unless (/\.srt$/.match(file_name)).nil?
  end
end
fix=SubtitleEncodingFixer.new(subtitle_source: ARGV[0])
fix.convert_to_utf8
