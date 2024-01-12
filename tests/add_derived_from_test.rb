require 'minitest/autorun'
require 'linkeddata'

class SparqlTest < Minitest::Test
  def setup
    sparql_path = "../sparqls/add_derived_from.sparql"
    sparql_file = File.read(sparql_path)
    @derived_from_url = "http://example.com/person1"
    sparql_file_with_url = sparql_file.gsub("subject_url", @derived_from_url)
    @sparql = SPARQL.parse(sparql_file_with_url, update: true)
  end

  #check the count of derivedFrom triples
  def test_derived_from_count
    graph = RDF::Graph.load("./fixtures/missing_derived_from.jsonld")
    # puts "before: #{graph.dump(:jsonld)}"
    graph.query(@sparql)
    # puts "after: #{graph.dump(:jsonld)}"
    assert_equal 1,graph.query([nil, RDF::Vocab::PROV.wasDerivedFrom, RDF::URI(@derived_from_url)]).count
  end

  #test to confirm postal address has no derived from
  def test_if_postal_address_has_derived_from
    graph = RDF::Graph.load("./fixtures/missing_derived_from.jsonld")
    # puts "before: #{graph.dump(:jsonld)}"
    graph.query(@sparql)
    # puts "after: #{graph.dump(:jsonld)}"
    assert_nil graph.query([RDF::URI("http://example.com/test_address"), RDF::Vocab::PROV.wasDerivedFrom, RDF::URI(@derived_from_url)])
  end
end
