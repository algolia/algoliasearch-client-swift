# NOTE: This `Podfile` is for the unit tests.
# The main pod is defined in the `Podspec`, of course.
#
# Linking the unit tests via Cocoapods brings the following benefits:
# - It makes sure that the pod is working.
# - Dependencies can be linked automatically.

use_frameworks!

def common_deps
    pod 'AlgoliaSearch-Client-Swift', :path => '.'
end

target "AlgoliaSearch-iOS-Tests" do
    common_deps
end

target "AlgoliaSearch-OSX-Tests" do
    common_deps
end
