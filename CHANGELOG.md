# ChangeLog

## [8.20.1](https://github.com/algolia/algoliasearch-client-swift/compare/8.20.0...8.20.1) (2024-03-04)

### Fix

- **analytics**: add region support (#856) ([94f90ebc](https://github.com/algolia/algoliasearch-client-swift/commit/94f90ebc))

## [8.20.0](https://github.com/algolia/algoliasearch-client-swift/compare/8.19.0...8.20.0) (2023-02-02)

### Misc

- chore: replace swift-log with oslog (#850)

## [8.19.0](https://github.com/algolia/algoliasearch-client-swift/compare/8.18.2...8.19.0) (2023-12-07)

### Misc

- fix(client configuration): default headers not applied (#839) ([f7745ae](https://github.com/algolia/algoliasearch-client-swift/commit/f7745ae))
- feat(search disjunctive faceting): add request options (#840) ([5a21b35](https://github.com/algolia/algoliasearch-client-swift/commit/5a21b35))
- chore(api key test): skip if failed (#835) ([7355d13](https://github.com/algolia/algoliasearch-client-swift/commit/7355d13))



## [8.18.2](https://github.com/algolia/algoliasearch-client-swift/compare/8.18.1...8.18.2) (2023-08-15)

### Fix

- **AsyncOperation**: cancel() and isCancelled behavior (#801) ([c060289](https://github.com/algolia/algoliasearch-client-swift/commit/c060289))



## [8.18.1](https://github.com/algolia/algoliasearch-client-swift/compare/8.18.0...8.18.1) (2023-06-22)

### Fix

- matching errors in the retry strategy (#817) ([0726cc5](https://github.com/algolia/algoliasearch-client-swift/commit/0726cc5))
- added conditional FoundationNetworking import to AlgoliaRetryStrategy.swift (#815) ([1281375](https://github.com/algolia/algoliasearch-client-swift/commit/1281375))



## [8.18.0](https://github.com/algolia/algoliasearch-client-swift/compare/8.17.0...8.18.0) (2023-03-24)

### Feat

- **rules**: add applied rules to the search response (#812) ([c25ec23](https://github.com/algolia/algoliasearch-client-swift/commit/c25ec23))

### Misc

- making result public (#807) ([150970e](https://github.com/algolia/algoliasearch-client-swift/commit/150970e))



## [8.17.0](https://github.com/algolia/algoliasearch-client-swift/compare/8.16.0...8.17.0) (2023-02-06)

### Fix

- provide user agents as url parmeter (#808) ([43f6105](https://github.com/algolia/algoliasearch-client-swift/commit/43f6105))
- lint issues (#809) ([09622f8](https://github.com/algolia/algoliasearch-client-swift/commit/09622f8))



## [8.16.0](https://github.com/algolia/algoliasearch-client-swift/compare/8.15.1...8.16.0) (2022-10-24)

### Feat

- **search**: Disjunctive Faceting (#802) ([b2a82ba](https://github.com/algolia/algoliasearch-client-swift/commit/b2a82ba))



## [8.15.1](https://github.com/algolia/algoliasearch-client-swift/compare/8.15.0...8.15.1) (2022-08-29)

### Fix

- URL percent encoding (#798) ([b28ebf1](https://github.com/algolia/algoliasearch-client-swift/commit/b28ebf1))



## [8.15.0](https://github.com/algolia/algoliasearch-client-swift/compare/8.14.0...8.15.0) (2022-08-04)

### Refactor

- consistent error handling (#792) ([23b1989](https://github.com/algolia/algoliasearch-client-swift/commit/23b1989))



## [8.14.0](https://github.com/algolia/algoliasearch-client-swift/compare/...8.14.0) (2022-03-18)

### Fix
- Optional avg and sum fields in facet stats (#786) ([f10e119](https://github.com/algolia/algoliasearch-client-swift/commit/f10e119ba4578e4f091150f7a39f28ff101171e6))


### Refactor
 
- Rename Task -> IndexTask (#787) ([6aa3e87](https://github.com/algolia/algoliasearch-client-swift/commit/6aa3e872e19c08c23a5d411bc242fbdc108b0513))



## [8.13.4](https://github.com/algolia/algoliasearch-client-swift/compare/...8.13.4) (2022-02-21)

### Fix

- Change `ObjectsResponse` results type constraint from `Codable` to `Decodable` (#783) ([62acdb7](https://github.com/algolia/algoliasearch-client-swift/commit/62acdb7))



## [8.13.3](https://github.com/algolia/algoliasearch-client-swift/compare/...8.13.3) (2022-01-21)

### Fix

- Url percent encoding according to RFC 3986 (#781) ([43c77ce](https://github.com/algolia/algoliasearch-client-swift/commit/43c77ce))



## [8.13.2](https://github.com/algolia/algoliasearch-client-swift/compare/...8.13.2) (2022-01-12)

### Fix

- Query url encoding issue with plus sign (#772) ([0af9644](https://github.com/algolia/algoliasearch-client-swift/commit/0af9644))



## [8.13.1](https://github.com/algolia/algoliasearch-client-swift/compare/...8.13.1) (2021-12-22)

### Fix

- Move API key to body if the key's length > 500 chars (#769) ([c1be4fb](https://github.com/algolia/algoliasearch-client-swift/commit/c1be4fb))



## [8.13.0](https://github.com/algolia/algoliasearch-client-swift/compare/...8.13.0) (2021-12-13)

### Feat

- Replace static UserAgent with UserAgent extensions (#764) ([52a682b](https://github.com/algolia/algoliasearch-client-swift/commit/58ad2eb))

### Fix

-  Around precision url component conversion issue (#765) ([58ad2eb](https://github.com/algolia/algoliasearch-client-swift/commit/52a682b))

### Refactor

- URL paths construction (#762) ([72dfa0e](https://github.com/algolia/algoliasearch-client-swift/commit/72dfa0e))



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

