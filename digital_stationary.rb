#!/opt/local/bin/ruby

require 'tempfile'
require 'rubygems'
require 'escape'

class PDFStationaryStamper
  attr_accessor :document_title, :job_details, :source_pdf, :stationary_pdf, :temp_directory, :pdftk_exec

  def initialize(data = nil)
    return unless data
    
    @stationary_pdf = data[:stationary]
    @document_title = data[:input][0]
    @job_details    = data[:input][1]
    @source_pdf     = data[:input][2]
    
    data[:config] ||= {}
    @temp_directory = data[:config][:temp_dir]   || '/private/tmp'
    @pdftk_exec     = data[:config][:pdftk_exec] || '/usr/local/bin/pdftk'
  end
  
  def stamp!
    tmpfile = ::Tempfile.new(@document_title, @temp_directory) # name generation only...
    filename = tmpfile.path + '.pdf'
    
    %x{#{Escape.shell_command([ @pdftk_exec, @stationary_pdf, 'background', @source_pdf , 'output', filename])}}
    
    Thread.abort_on_exception = true
    t1 = Thread.new do
      %x{#{Escape.shell_command([ 'open', filename])}}  
    end
  end
end


fs = PDFStationaryStamper.new(:input => ARGV, :stationary => '/Users/rmoriz/stationary.pdf')
fs.stamp!
