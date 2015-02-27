require 'mediawiki_api'

if ARGV.empty?
    puts "Title required!"
else
    client = MediawikiApi::Client.new "http://pl.wikipedia.org/w/api.php"
    File.open("testwt", "w") do |f|
        f << client.get_wikitext(ARGV.first).body
    end
end