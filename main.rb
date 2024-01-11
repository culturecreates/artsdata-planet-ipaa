require 'nokogiri'
require 'open-uri'
require 'linkeddata'

if ARGV.length != 6
  puts "Usage: ruby script_name.rb <page_url> <base_url> <entity_identifier> <file_name> <is_paginated> <href_tag>"
  exit
end

page_url = ARGV[0]
base_url = ARGV[1]
entity_identifier = ARGV[2]
file_name = ARGV[3]
is_paginated = ARGV[4]
href_tag = ARGV[5]
max_retries, retry_count = 3, 0
page_number = is_paginated == 'true' ? 1 : nil
graph = RDF::Graph.new
add_url_sparql = "./sparqls/add_derived_from.sparql"
add_url_sparql_file = File.read(add_url_sparql)

loop do
  url = "#{page_url}#{page_number}"
  begin
    main_page_html_text = URI.open(url).read
  rescue StandardError => e
    retry_count += 1
    if retry_count < max_retries
      retry
    else
      puts "Max retries reached. Unable to fetch the content for page #{page_number}."
      break
    end
  end

  main_doc = Nokogiri::HTML(main_page_html_text)
  entities_data = main_doc.css(entity_identifier)
  entity_urls = []
  entities_data.each do |entity|
    href = entity[href_tag]
    entity_urls << base_url+href
  end
  if entity_urls.empty?
    puts "No more entities found on page #{page_number}. Exiting..."
    break
  end

  entity_urls.each do |entity_url|
    begin
      entity_url = entity_url.gsub(' ', '+')
      loaded_graph = RDF::Graph.load(entity_url)
      sparql_file_with_url = add_url_sparql_file.gsub("subject_url", entity_url)
      loaded_graph.query(SPARQL.parse(sparql_file_with_url, update: true))
      graph << loaded_graph
    rescue StandardError => e
      puts "Error loading RDF from #{entity_url}: #{e.message}"
      break
    end
  end
  if page_number == nil
    break
  else
    page_number += 1
  end
  retry_count = 0
end

sparql_file = "./sparqls/replace_blank_nodes.sparql"
graph.query(SPARQL.parse(File.read(sparql_file), update: true))

File.open(file_name, 'w') do |file|
  file.puts(graph.dump(:jsonld))
end
