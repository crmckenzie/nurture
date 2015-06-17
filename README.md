# Nurture API

Provides an api spec and a sample implementation for a staged release management process.

## Abstract

To begin work on a project developers create a manifest of application versions
that will be modified for the project.

Manifests can then be associated to environments. An environment is a container
of all production application versions with the modifications provided by the
manifest.

Once work is completed on the project, a manifest can be released. This results
in prod versions being updated to include the new work.

The dominant goal is to support the following

* Provide a discriminated, separately securable step for releasing an application.
* Describe an environment by what is *different* than production
* Query release history by application
* Determine what project(s) are associated with a release
* Query application version(s) applied to a particular environment
* Query application version(s) currently deployed to prod

## Documents
- [Swagger Docs](swagger.yml)
- [Task List](TASKLIST.md)
