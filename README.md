# artsdata-planet-ipaa
Indigenous Performing Arts Association - workflows for loading data into Artsdata

Manually trigger the [workflow](https://github.com/culturecreates/artsdata-planet-ipaa/actions/workflows/ipaa-sitemap-entities.yml) to crawl the IPAA website and publish all of the artists and organizations listed in the sitemap to Artsdata.

## Nebula

View IPAA Entities in Artsdata.ca with the [Nebula viewer](http://kg.artsdata.ca/query/show?sparql=https%3A%2F%2Fraw.githubusercontent.com%2Fculturecreates%2Fartsdata-planet-ipaa%2Fmain%2Fsparqls%2Fnebula%2Fipaa_entities.sparql&title=IPAA+People+and+Organizations) using the [sparql](https://github.com/culturecreates/artsdata-planet-ipaa/blob/main/sparqls/nebula/ipaa_entities.sparql) in this repo.

Data for Wikidata upload is [here](http://kg.artsdata.ca/query/show?sparql=https%3A%2F%2Fraw.githubusercontent.com%2Fculturecreates%2Fartsdata-planet-ipaa%2Fmain%2Fsparqls%2Fnebula%2Fdata_for_wikidata.sparql&title=IPAA+data+for+Wikidata).

Check for artists no longer member 
[here](http://kg.artsdata.ca/query/show?sparql=https%3A%2F%2Fraw.githubusercontent.com%2Fculturecreates%2Fartsdata-planet-ipaa%2Fmain%2Fsparqls%2Fnebula%2Fcheck_for_artists_not_members.sparql&title=Artist+IPAA+Members+Report) according to Wikidata dates.
