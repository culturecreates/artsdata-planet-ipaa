require 'minitest/autorun'
require 'linkeddata'

class SparqlTest < Minitest::Test

  # Load and parse sparql
  def setup
    @sparql_file = "../sparqls/replace_blank_nodes.sparql"
    derived_from_url = "http://example.com/person1"
    @sparql = SPARQL.parse(File.read(@sparql_file).gsub("subject_url",derived_from_url), update: true)
  end

  # check that the blank node is replaced
  def test_basic
    graph = RDF::Graph.load("./fixtures/basic.jsonld")
    # puts "before: #{graph.dump(:turtle)}"
    assert_equal true, graph.first.subject.node? 
    graph.query(@sparql)
    # puts "after: #{graph.dump(:turtle)}"
    assert_equal false, graph.first.subject.node? 
  end

  # check that the number of entities remains the same
  def test_two_entities
    graph = RDF::Graph.load("./fixtures/two_entities.jsonld")
    graph.query(@sparql)
    # puts graph.dump(:turtle)
    expected = 2
    assert_equal expected, graph.subjects.count
  end

  # test that nested blank nodes ("Mexico") remain blank
  def test_nested
    graph = RDF::Graph.load("./fixtures/nested_blank.jsonld")
    graph.query(@sparql)
    # puts graph.dump(:turtle)
    assert_equal true, graph.query([nil, RDF::Vocab::SCHEMA.addressCountry, RDF::Literal("Mexico")]).each.subjects.node?
  end

  # test that the person does not have a blank node
  def test_ipaa_person
    sparql = SPARQL.parse(File.read(@sparql_file).gsub("subject_url","https://ipaa.ca/profile/indigenous-artist/Martin+Desjarlais"), update: true)
    graph = RDF::Graph.load("./fixtures/ipaa_person.jsonld")
    graph.query(sparql)
    # puts graph.dump(:turtle)
    assert_equal false, graph.query([nil, RDF::type, RDF::URI("http://schema.org/Person")]).each.subjects.node?
  end

end

