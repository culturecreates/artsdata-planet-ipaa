require 'nokogiri'
require 'open-uri'
require 'linkeddata'

if ARGV.length != 2
  puts "Usage: ruby script_name.rb <sitemap_url>  <file_name>"
  exit
end

sitemap_url = ARGV[0]
file_name = ARGV[1]

graph = RDF::Graph.new

add_url_sparql = "./sparqls/add_derived_from.sparql"
add_url_sparql_file = File.read(add_url_sparql)

sitemap_xml = Nokogiri::XML(URI.open(sitemap_url))
# Extract all URLs from the sitemap
ns = { 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9' }
entity_urls = sitemap_xml.xpath('//xmlns:url/xmlns:loc', ns).map(&:text)

entity_urls.each do |entity_url|
  begin
    entity_url = entity_url.gsub(' ', '+')
    loaded_graph = RDF::Graph.load(entity_url)
    sparql_file_with_url = add_url_sparql_file.gsub("subject_url", entity_url)
    loaded_graph.query(SPARQL.parse(sparql_file_with_url, update: true))
    graph << loaded_graph
  rescue StandardError => e
    puts "Error loading RDF from #{entity}: #{e.message}"
    break
  end
end

sparql_file = "./sparqls/replace_blank_nodes.sparql"
graph.query(SPARQL.parse(File.read(sparql_file), update: true))

File.open(file_name, 'w') do |file|
  file.puts(graph.dump(:jsonld))
end
