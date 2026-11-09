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

// Ba'zi pluginlar (masalan onnxruntime) eski compileSdk bilan keladi, AndroidX
// esa compileSdk >= 34 talab qiladi. Barcha kutubxona modullarini bitta
// zamonaviy compileSdk ga keltiramiz. Bu blok evaluationDependsOn'dan OLDIN
// turishi kerak — aks holda loyiha allaqachon baholangan bo'ladi.
subprojects {
    afterEvaluate {
        val ext = extensions.findByName("android")
        if (ext is com.android.build.api.dsl.LibraryExtension) {
            ext.compileSdk = 36
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
