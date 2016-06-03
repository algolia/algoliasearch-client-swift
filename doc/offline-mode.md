

# Offline mode

## Overview

The API client can be enhanced with offline capabilities. This optional **offline mode** allows you to mirror online indices on local storage, and transparently switch to the local mirror in case of unavailability of the online index, thus providing uninterrupted user experience. You can also explicitly query the mirror if you want.

Because indices can be arbitrarily big, whereas mobile devices tend to be constrained by network bandwidth, disk space or memory consumption, only part of an index's data is usually synchronized (typically the most popular entries, or what's relevant to the user, or close to her location...). The offline mode lets you control which data subset you want to synchronize, and how often to synchronize it.

Index settings are automatically synchronized, so that your local index will behave exactly as your online index, with a few restrictions:

- If only part of the data is mirrored, queries may obviously return less objects. Counts (hits, facets...) may also differ.

- Some advanced features are not supported offline. See [Unsupported features](#unsupported-features) for more information.


### Availability

Offline features are brought by Algolia's **Offline SDK**, which is actually composed of two separate components:

- The **Offline API Client** is a superset of the regular, online API client (so all your existing code will work without any modification). It is open source; the source code is available on GitHub in the same repository as the online [Swift API client](https://github.com/algolia/algoliasearch-client-swift).

- The **Offline Core** is a closed source component using native libraries. Although it is readily available for download, *it is licensed separately*, and will not work without a valid **license key**. Please [contact us](https://www.algolia.com/) for more information.



## Setup

### Prerequisites

1. Obtain a **license key** from [Algolia](https://www.algolia.com/).

2. Make sure you use an **API key** with the following ACLs:

    - Search (`search`)
    - Browse (`browse`)
    - Get index settings (`settings`)

    *This is required because the offline mode needs to replicate the online index's settings and uses browse requests when syncing.*


### Steps

2. In your Podfile, reference the offline pod:

    ```ruby
    pod 'AlgoliaSearch-Offline-Swift', '~> ${WHATEVER_IS_THE_LATEST_VERSION}'
    ```

    *NOTE: Because of its intrinsic limitations, Carthage is **not** supported for the offline mode.*

3. When initializing your client, instantiate an `OfflineClient` instead of a `Client`:

    ```swift
    client = OfflineClient(appID: "YOUR_APP_ID", apiKey: "YOUR_API_KEY")
    ```

4. (Optional) Choose the directory under which local indices will be stored:

    ```swift
    client.rootDataDir = TODO
    ```

    By default, TODO.

    *Warning: although using the cache directory may be tempting, we advise you against doing so. There is no guarantee that all files will be deleted together, and a partial delete could leave an index in an inconsistent state.*

5. **Enable offline mode**:

    ```java
    client.enableOfflineMode("YOUR_OFFLINE_CORE_LICENSE_KEY")
    ```


## Usage

### Activation

An `OfflineClient` provides all the features of an online `Client`. It returns `MirroredIndex` instances, which in turn provide all the features of online `Index` instances.

However, until you explicitly enable the offline mode by calling `enableOfflineMode()`, your offline client behaves like a regular online client. The same goes for indices: *you must explicitly activate mirroring* by settings the `mirrored` property to `true`. The reason is that you might not want to mirror all of your indices.

*Warning: Calling offline features before enabling mirroring on an index is a programming error and will be punished by an assertion failure.*


### Synchronization

You have entire control over *what* is synchronized and *when*.

#### What

First, specify what subset of the data is to be synchronized. You do so by constructing **data selection queries** and setting the `MirroredIndex.dataSelectionQueries` property.

A *data selection query* is essentially a combination of a browse `Query` and a maximum object count. When syncing, the offline index will browse the online index, filtering objects through the provided query (which can be empty, hence selecting all objects), and stopping when the maximum object count has been reached (or at the end of the index, whichever comes first).

It will do so for every data selection query you have provided, then build (or re-build) the local index from the retrieved data. (When re-building, the previous version of the local index remains available for querying, until it is replaced by the new version.)

*Warning: The entire selected data is re-downloaded at every sync, so be careful about bandwidth usage!*

*Warning: It is a programming error to attempt a sync with no data selection queries. Doing so will result in an assertion failure.*

*Note: Because the sync uses a "browse" to retrieve objects, the number of objects actually mirrored may exceed the maximum object count specified in the data selection query (up to one page of results of difference).*


#### When

The easiest way to synchronize your index is to use the **semi-automatic mode**:

- Choose a minimum delay between two syncs by setting `MirroredIndex.delayBetweenSyncs`. The default is 24 hours.

- Whenever conditions are met for a potential sync (e.g. the device is online), call `MirroredIndex.syncIfNeeded()`. If the last successful sync is older than the minimum delay, a sync will be launched. Otherwise, the call will be ignored.

Alternatively, you may call `MirroredIndex.sync()` to force a sync to happen now.

The reason you have to choose when to synchronize is that the decision depends on various factors that the SDK cannot know, in particular the specific business rules of your application, or the user's preferences. For example, you may want to sync only when connected to a non-metered Wi-Fi network, or during the night.

*Note: Syncs always happen in the background, and therefore should not impact the user's experience.*

*Note: You cannot have two syncs on the same index running in parallel. If a sync is already running, concurrent sync requests will be ignored.*


### Querying

#### Transparent fallback mode

You query a mirrored index using the same `search()` method as a purely online index. This will use the offline mirror as a fallback in case of failure of the online request.

There's a catch, however. A mirrored index can function in two modes:

1. **Preventive offline search** (default). In this mode, if the online request is too slow to return, an offline request is launched preventively after a certain delay.

    *Warning: This may lead to your completion handler being called twice:* a first time with the offline results, and a second time with the online results. However, if the online request is fast enough (and successful, or the error cannot be recovered), the callback will be called just once.

    You may adjust the delay setting the `MirroredIndex.preventiveOfflineSearchDelay` property. The default is `MirroredIndex.DefaultPreventiveOfflineSearchDelay`.

2. **Offline fallback.** In this mode, the index first tries an online request, and in case of failure, switches back to the offline mirror, but only after the online request has failed. Therefore, the completion handler is guaranteed to be called exactly once.

You can switch between those two modes by setting `MirroredIndex.preventiveOfflineSearch`.

The origin of the data is indicated by the `origin` attribute in the returned result object: its value is `remote` if the content originates from the online API, and `local` if the content originates from the offline mirror.


#### Direct query

You may directly target the offline mirror if you want:

- for search queries: `searchMirror()`
- for browse queries: `browseMirror()` and `browseMirrorFrom()`

Those methods have the same semantics as their online counterpart.

Browsing is especially relevant when synchronizing [associated resources](#associated-resources).


### Events

You may be informed of sync events by registering a notification observer on the index for the `MirroredIndex.SyncDidStartNotification` and `MirroredIndex.SyncDidFinishNotification` notifications.


### Associated resources

In a typical setup, objects from an index are not standalone. Rather, they reference other resources (for example images) that are stored outside of Algolia. They are called **associated resources**.

In order to offer the best user experience, you may want to pre-load some of those resources while you are online, so that they are available when offline.

To do so:

- register a listener on the mirrored index (see [Events](#events) above);
- when the sync is finished, browse the local mirror, parsing each object to detect associated resources;
- pre-fetch those that are not already available locally.

*Note: You should do so from a background thread with a low priority to minimize impact on the user's experience.*



## Unsupported features

Due mainly to binary size constraints, the following features are not supported by the offline mode:

- plurals dictionary (simple plurals with a final S are still handled)
- CJK segmentation
- IP geolocation (`aroundLatLngViaIP` query parameter)



## Troubleshooting

### Logs

The SDK logs messages to the console, which can be useful when troubleshooting.

If the SDK does not seem to work, first check for proper initialization in the logs. You should see something like:

```
Algolia SDK v1.2.3
Algolia SDK licensed to: Peanuts, Inc.
```

Any unexpected condition should result in a warning/error being logged.


### Support

If you think you found a bug in the offline client, please submit an issue on GitHub so that it can benefit the community.

If you have a crash in the offline core, please send us a support request. Make sure to include the *crash report*, so that we can pinpoint the problem.


## Other resources

The offline client bears extensive documentation comments. Please refer to them for more details.

