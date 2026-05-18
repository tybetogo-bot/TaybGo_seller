allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

subprojects {
    buildscript {
        configurations.configureEach {
            resolutionStrategy.eachDependency {
                when {
                    requested.group == "com.android.tools.build" && requested.name == "gradle" ->
                        useVersion("8.13.1")

                    requested.group == "org.jetbrains.kotlin" && requested.name == "kotlin-gradle-plugin" ->
                        useVersion("2.2.20")
                }
            }
        }
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

    afterEvaluate {
        if (project.hasProperty("android")) {
            project.extensions.configure<com.android.build.gradle.BaseExtension>("android") {
                compileSdkVersion(36)
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
