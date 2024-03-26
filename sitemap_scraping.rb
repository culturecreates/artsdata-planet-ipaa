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
add_url_sparql_file = File.read("./sparqls/add_derived_from.sparql")
replace_blank_nodes_sparql_file = File.read("./sparqls/replace_blank_nodes.sparql")

sitemap_xml = Nokogiri::XML(URI.open(sitemap_url))
# Extract all URLs from the sitemap
ns = { 'xmlns' => 'http://www.sitemaps.org/schemas/sitemap/0.9' }
entity_urls = sitemap_xml.xpath('//xmlns:url/xmlns:loc', ns).map(&:text)

entity_urls.each do |entity_url|
  begin
    loaded_graph = RDF::Graph.load(entity_url)
    # add derivedFrom
    sparql = SPARQL.parse(add_url_sparql_file.gsub("subject_url", entity_url), update: true)
    loaded_graph.query(sparql)
    # replace blank nodes
    uri = entity_url.gsub('%20', '_')
    sparql = SPARQL.parse(replace_blank_nodes_sparql_file.gsub("subject_url",uri ), update: true)
    loaded_graph.query(sparql)

    graph << loaded_graph
  rescue StandardError => e
    puts "Error loading RDF from #{entity}: #{e.message}"
    break
  end
end

File.open(file_name, 'w') do |file|
  file.puts(graph.dump(:jsonld))
end
