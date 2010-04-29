#!/opt/local/bin/ruby

require 'tempfile'
require 'rubygems'
require 'escape'

class PDFStationeryStamper
  attr_accessor :document_title, :job_details, :source_pdf, :stationery_pdf, :temp_directory, :pdftk_exec

  def initialize(data = nil)
    return unless data
    
    @stationery_pdf = data[:stationery]
    @document_title = data[:input][0]
    @job_details    = data[:input][1]
    @source_pdf     = data[:input][2]
    
    data[:config] ||= {}
    @temp_directory = data[:config][:temp_dir]   || '/private/tmp'
    @pdftk_exec     = data[:config][:pdftk_exec] || '/usr/local/bin/pdftk'
  end
  
  def stamp!
    tmpfile = ::Tempfile.new('digital_stationery_tmp', @temp_directory) # name generation only
    filename = tmpfile.path + '.pdf'
    
    %x{#{Escape.shell_command([@pdftk_exec, @source_pdf , 'stamp', @stationery_pdf, 'output', filename])}}
    
    Thread.abort_on_exception = true
    t1 = Thread.new do
      %x{#{Escape.shell_command([ 'open', filename])}}  
    end
  end
end


fs = PDFStationeryStamper.new(:input => ARGV, :stationery => '/Users/rmoriz/stationery.pdf')
fs.stamp!
