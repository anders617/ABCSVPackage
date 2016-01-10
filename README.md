# ABCSV Package
Testing the Swift Package Manager for Swift 2.2 using the ABCSV library.

###Installation
In order to add this as a dependency, create a Package.swift file in the project directory with the following code:

    import PackageDescription
    
    let package = Package(
      name: "PROJECT_NAME",
      dependencies: [
        .Package(url: "https://github.com/anders617/ABCSVPackage.git", majorVersion:1),
      ]
    )

Note: You must be running [Swift 2.2](https://swift.org/download/) and correctly format your project's directory to be compatible with the [Swift Package Manager](https://swift.org/package-manager/#conceptual-overview)
