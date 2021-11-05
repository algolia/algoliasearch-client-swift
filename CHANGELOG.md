# ChangeLog

## [8.12.0](https://github.com/algolia/algoliasearch-client-swift/compare/...8.12.0) (2021-11-05)

### Feat

- Client-level search method (#751) ([775d8cd](https://github.com/algolia/algoliasearch-client-swift/commit/775d8cd))



## [8.11.0](https://github.com/algolia/algoliasearch-client-swift/compare/...8.11.0) (2021-10-06)

### Feat

- Implement Recommend client (#753) ([37b0046](https://github.com/algolia/algoliasearch-client-swift/commit/37b0046))
- Implement enableReRanking search attribute (#757) ([9b0baf0](https://github.com/algolia/algoliasearch-client-swift/commit/9b0baf0))



## [8.10.0](https://github.com/algolia/algoliasearch-client-swift/compare/...8.10.0) (2021-07-13)

### Feat

- Add abTestID to the search response (#749)

### Fix

- Make the RetryableHost initializer public (#747)



## [8.9.0](https://github.com/algolia/algoliasearch-client-swift/compare/8.8.1...8.9.0) (2021-07-07)

### Feat

- Dynamic facet ordering support (#739)

### Fix

- Resolve conflict between TimeInterval convenient methods and DispatchTimeInterval (#744)
- Add missing virtual replicas parameter coding (#743)

### Misc

- Rename Recommendation -> Personalization (#745)



## [8.8.1](https://github.com/algolia/algoliasearch-client-swift/compare/8.8.0...8.8.1) (2021-03-03)

### Fix

- set the correct json decoding key for indexName field in the SearchResponse (#735) ([e4738cd](https://github.com/algolia/algoliasearch-client-swift/commit/e4738cd))



## [8.8.0](https://github.com/algolia/algoliasearch-client-swift/compare/8.7.0...8.8.0) (2021-03-01)

### Refactor

- Transport and logging improvements (#730) ([5a10763](https://github.com/algolia/algoliasearch-client-swift/commit/5a10763))



## [8.7.0](https://github.com/algolia/algoliasearch-client-swift/compare/8.6.0...8.7.0) (2021-02-15)

### Misc

- feat(virtual indices): Virtual indices related parameters (#727) ([3573863](https://github.com/algolia/algoliasearch-client-swift/commit/3573863))



## [8.6.0](https://github.com/algolia/algoliasearch-client-swift/compare/8.5.0...8.6.0) (2021-02-03)

### Feat

- Custom dictionaries (#717) ([c3103b4](https://github.com/algolia/algoliasearch-client-swift/commit/c3103b4))
- Add `attributesToTransliterate` settings parameter (#723) ([722750b](https://github.com/algolia/algoliasearch-client-swift/commit/722750b))

### Fix

- Update carthage dependencies and prebuild script (#725) ([ab8a46d](https://github.com/algolia/algoliasearch-client-swift/commit/ab8a46d))
- AB test variant fields nullability (#720) ([b97fefe](https://github.com/algolia/algoliasearch-client-swift/commit/b97fefe))

### Misc

- Add `decompoundQuery` search & settings parameter (#722) ([2e5fa23](https://github.com/algolia/algoliasearch-client-swift/commit/2e5fa23))
- Add `filters` field to Rule condition (#721) ([8d927d1](https://github.com/algolia/algoliasearch-client-swift/commit/8d927d1))



## [8.5.0](https://github.com/algolia/algoliasearch-client-swift/compare/8.4.2...8.5.0) (2021-01-18)

### Feat

- Algolia Answers (#701) ([de625ca](https://github.com/algolia/algoliasearch-client-swift/commit/de625ca))

### Misc

- Add DOCKER_README and update README with Docker section (#703) ([eefc439](https://github.com/algolia/algoliasearch-client-swift/commit/eefc439))



## [8.4.2](https://github.com/algolia/algoliasearch-client-swift/compare/8.4.1...8.4.2) (2020-12-21)

### Fix

- Missing content-type header for async InsightsClient.sendEvents call (#710) ([e2c92f0](https://github.com/algolia/algoliasearch-client-swift/commit/e2c92f0))



## [8.4.1](https://github.com/algolia/algoliasearch-client-swift/compare/8.4.0...8.4.1) (2020-12-18)

### Fix

- HostIterator crash (#708) ([8396f77](https://github.com/algolia/algoliasearch-client-swift/commit/8396f77))



## [8.4.0](https://github.com/algolia/algoliasearch-client-swift/compare/8.3.0...8.4.0) (2020-12-17)

### Feat

- hit _geoloc field improvement (#704) ([b13998c](https://github.com/algolia/algoliasearch-client-swift/commit/b13998c))



## [8.3.0](https://github.com/algolia/algoliasearch-client-swift/compare/8.2.0...8.3.0) (2020-11-23)

### Fix

- FilterStorage URL encoding (#698) ([f026af1](https://github.com/algolia/algoliasearch-client-swift/commit/f026af1))
- Tagged string subrange calculation crash (#661) ([82d2fc5](https://github.com/algolia/algoliasearch-client-swift/commit/82d2fc5))
- License link in Readme (#695) ([7db6835](https://github.com/algolia/algoliasearch-client-swift/commit/7db6835))

### Feat

- Server side swift (#680) ([423400f](https://github.com/algolia/algoliasearch-client-swift/commit/423400f))

### Refactor

- Rename replaceExistingSynonyms into clearExistingSynonyms (#696) ([410c34a](https://github.com/algolia/algoliasearch-client-swift/commit/410c34a))



## [8.2.0](https://github.com/algolia/algoliasearch-client-swift/compare/8.1.3...8.2.0) (2020-11-03)

### Feat

- set tagged/untagged ranges calculation lazy in TaggedString (#689) ([59daf69](https://github.com/algolia/algoliasearch-client-swift/commit/59daf69))



## [8.1.3](https://github.com/algolia/algoliasearch-client-swift/compare/8.1.2...8.1.3) (2020-10-27)

### Fix

- Make tag parsing for highlighted strings diacritic insensitive (#683) ([2c84258](https://github.com/algolia/algoliasearch-client-swift/commit/2c84258))
- Change averageClickPosition of the ABTestResponse.Variant type to Double (#682) ([920a2d7](https://github.com/algolia/algoliasearch-client-swift/commit/920a2d7))

### Misc

- Version 8.1.2 (#679) ([e028c43](https://github.com/algolia/algoliasearch-client-swift/commit/e028c43))
- Version 8.1.2 ([eb1db8d](https://github.com/algolia/algoliasearch-client-swift/commit/eb1db8d))


