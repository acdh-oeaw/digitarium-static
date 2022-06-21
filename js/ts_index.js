const typesenseInstantsearchAdapter = new TypesenseInstantSearchAdapter({
    server: {
      apiKey: "9B1PUuRZU5szyFE6HZGRHi19f03aWIql",
      nodes: [
        {
          host: "typesense.acdh-dev.oeaw.ac.at",
          port: "443",
          protocol: "https",
        },
      ],
      cacheSearchResultsForSeconds: 2 * 60,
    },
    additionalSearchParameters: {
      query_by: "full_text"
    },
  });


const searchClient = typesenseInstantsearchAdapter.searchClient;
const search = instantsearch({
    indexName: 'digitarium',
    searchClient,
});

search.addWidgets([
    instantsearch.widgets.searchBox({
        container: '#searchbox',
    }),

    instantsearch.widgets.hits({
        container: '#hits',
        templates: {
            empty: 'No results',
            item: `
                <h4> {{ id }}</h4>
                <h5><a href="{{ id }}.html">{{ title }}</a></h5>
                <p>{{#helpers.snippet}}{ "attribute": "full_text" }{{/helpers.snippet}}</p>
            `
        }
    }),

    instantsearch.widgets.stats({
        container: '#stats-container'
    }),

    instantsearch.widgets.pagination({
        container: '#pagination',
        padding: 2,
    }),

    instantsearch.widgets.clearRefinements({
        container: '#clear-refinements',
    }),

    instantsearch.widgets.currentRefinements({
        container: '#current-refinements',
    }),
      
    instantsearch.widgets.rangeInput({
        container: '#range-input',
        attribute: 'year',
        step: 10,
        pips: true,
    })
]);



search.addWidgets([
    instantsearch.widgets.configure({
        attributesToSnippet: ['full_text'],
    })
]);


search.start();