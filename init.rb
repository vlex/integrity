$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "lib"))

# integrity.vlex.com uses bundler08, not bundler:
require "vendor/gems/environment"
require "integrity"

# Uncomment as appropriate for the notifier you want to use
# = Email
# integrity.vlex.com uses email notifications:
require "integrity/notifier/email"
# = IRC
# require "integrity/notifier/irc"
# = Campfire
# require "integrity/notifier/campfire"
# = TCP
# require "integrity/notifier/tcp"
# = HTTP
# require "integrity/notifier/http"
# = Notifo
# require "integrity/notifier/notifo"

Integrity.configure do |c|
  c.database     "sqlite3:integrity.db"
  c.directory    "builds"
  c.base_url     "http://integrity.vlex.com"
  c.log          "integrity.log"
  c.github       "SECRET"
  c.build_all!
  # integrity.vlex.com uses delayed_job:
  # c.builder      :threaded, 5
  c.builder :dj, :adapter => "sqlite3", :database => "dj.db"
end
