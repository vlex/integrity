# Make sure gems are loaded by the www user in integrity.vlex.com
ENV['PATH']="#{ENV['HOME']}/.gem/ruby/1.8/bin:#{ENV['PATH']}"
ENV['GEM_PATH']="#{ENV['HOME']}/.gem/ruby/1.8:#{ENV['GEM_PATH']}"
ENV['GEM_HOME']="#{ENV['HOME']}/.gem/ruby/1.8:#{ENV['GEM_HOME']}"

# Set a virtual display to redirect Firefox output
ENV["DISPLAY"] = ":20"

# Check if Xvfb is running (for headless Firefox) and run it again
if %x[ps -ef | grep "xinit" | grep -v grep].empty?
  auth_file = "#{ENV['HOME']}/X99.cfg"
  system "echo 'localhost' > #{auth_file}"
  system "xinit -- `which Xvfb` #{ENV['DISPLAY']} -screen 0 1024x768x24 -auth #{auth_file} 2>&1 > xinit.log &"
end

# Check if selenium is running and run it again
if %x[ps -ef | grep "selenium" | grep -v grep].empty?
  system "selenium > selenium.log 2>&1 &"
end

# Check if rake jobs:work is running and run it again
if %x[ps -ef | grep "rake jobs:work" | grep -v grep].empty?
  system "rake jobs:work > delayed_job.log 2>&1 &"
end

require "init"
run Integrity.app
