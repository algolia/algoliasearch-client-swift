
# Maintenance

*Note: This guide is intended for maintainers of this project.* If you are just using it, you don't need to read this.


## Online and offline flavors

The client exists in two different flavors:

- The **online** flavor, which is the regular API client. Its source code is located under the `Source` directory. It
  gets published to CocoaPods as `AlgoliaSearch-Client-Swift`.

- The **offline** flavor, which is a superset of the online flavor. In addition to the main source code, it adds the
  `Source/offline` directory. It gets published to CocoaPods as `AlgoliaSearch-Offline-Swift`. This flavor has a
  dependency on the Algolia Search Offline Core module (`AlgoliaSearchOfflineCore-iOS` in CocoaPods).

CocoaPods subspecs don't allow us to have different deployment platforms for each subspec. So, instead of using
subspecs, we use **two distinct pods**.

Although the project is published as two different pods, it is essentially the same code base. Therefore we wish to
keep versioning aligned (there is only one version number for both flavors).


## Deployment process

- Update the **version number** in:

    - `AlgoliaSearch-Client-Swift.podspec`

    - `AlgoliaSearch-Offline-Swift.podspec`

    - `Source/Info.plist` (or via Xcode, in the project settings)

- Update the **change log** (`ChangeLod.md`)

- **Dry-run the pod specs**: `pod lib lint` to check that everything's fine.

    WARNING: CocoaPods is a very susceptible beast, and Xcode (used behind the scenes for building) add its own layer
    of trouble on top of it. If you get weird, inexplicable behavior, try:

    - clearing Cocapods temporary directory (usually displayed in the error messages), which appears to be reused
      between two invocations of CocoaPods;

    - clearing Xcode derived data in `~/Library/Developer/Xcode/DerivedData`.

    NOTE: Currently, there are warnings we cannot avoid (see below).

- **Push to GitHub**:

    - `git commit -m "Version X.Y.Z"`

    - `git tag X.Y.Z`

    - `git push --tags origin master`

- Make sure you have a **CocoaPods session** open: `pod trunk me`. If you have no active session, use
  `pod trunk register EMAIL` to create one. (If you have never registered to CocoaPods, you need to contact one of
  the pod's owners; `pod trunk info` is your friend.)

- **Publish the pods.** You have to publish each pod separately:

    - `pod trunk push --allow-warnings AlgoliaSearch-Client-Swift.podspec`

    - `pod trunk push --allow-warnings AlgoliaSearch-Offline-Swift.podspec`

    NOTE: Currently, `--allow-warnings` is required. We get warnings about useless conditional compilation on iOS 8.0,
    but iOS 7 is really supported; it's just that it cannot be supported via CocoaPods.

- Edit the **release notes**: in GitHub, edit the tag and copy-paste the Change Log section for this release.
