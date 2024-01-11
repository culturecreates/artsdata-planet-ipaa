#!/usr/bin/env ruby

require 'linkeddata'

# creating an array of urls
urls = Array.new
urls << "https://ipaa.ca/profile/indigenous-organization/adaka"
urls << "https://ipaa.ca/profile/indigenous-organization/a11"

add_url_sparql = "./sparqls/add_derived_from.sparql"
add_url_sparql_file = File.read(add_url_sparql)

# creating the graph instance
graph = RDF::Graph.new

# looping through each url
urls.each do |url|
  begin
    url = url.gsub(' ', '+')
    loaded_graph = RDF::Graph.load(url)
    sparql_file_with_url = add_url_sparql_file.gsub("subject_url", url)
    loaded_graph.query(SPARQL.parse(sparql_file_with_url, update: true))
    graph << loaded_graph
  rescue  StandardError => e
    puts "Rescue: #{e.message}"
  end
end

# replacing blank nodes
sparql_file = "./sparqls/replace_blank_nodes.sparql"
graph.query(SPARQL.parse(File.read(sparql_file), update: true))

File.write('dump.jsonld', graph.dump(:jsonld))
# puts graph.dump(:turtle)
