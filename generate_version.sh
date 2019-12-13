version_number=`sed -n '/MARKETING_VERSION/{s/MARKETING_VERSION = //;s/;//;s/^[[:space:]]*//;p;q;}' ./AlgoliaSearch.xcodeproj/project.pbxproj`
version_file=Sources/AlgoliaSearch-Client/Version.swift
> $version_file
echo "// This is generated file. Don't modify it manually." >> $version_file
echo "public struct Version {" >> $version_file
echo "  public static let current = \""${version_number}"\"" >> $version_file
echo "}" >> $version_file
