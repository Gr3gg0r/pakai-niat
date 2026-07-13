allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

// isar_flutter_libs (unmaintained) ships no AGP namespace and an ancient
// compileSdk (android-30); AGP 8+ requires a namespace, and fresh androidx
// resolutions (fragment 1.7+) demand compileSdk >= 34. Configure in
// afterEvaluate so these values override the plugin's own build script, and
// register this BEFORE the evaluationDependsOn block below — that call
// eagerly evaluates subprojects, and late registration throws
// "Cannot run Project.afterEvaluate when the project is already evaluated".
subprojects {
    if (project.name == "isar_flutter_libs") {
        afterEvaluate {
            extensions.configure<com.android.build.gradle.LibraryExtension>("android") {
                namespace = "dev.isar.isar_flutter_libs"
                compileSdk = 34
            }
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
