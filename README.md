# Nurture API

Provides an api spec and a sample implementation for a staged release management process.

[Swagger Docs](swagger.yml)

## TODO

- implement a working swagger ui

### POST /releases

- merges application versions into the prod environment

### GET /releases

recent releases and the application versions that were a part of them

### GET /releases/:id

release with the given id

### DELETE /applications/:name

- removes an application (done)
- fails if the application has been released
- implies a need for archived applications that are not returned from /applications by default


### GET /applications/:name/versions

returns the version history of an application

### GET /applications/:name/releases

release history for a given application

### GET /applications/:name/manifests

returns a list of manifests associated with the application


### GET /environments/:name/application_versions

returns the list of application versions associated with the environment (all prod + modifications from manifests)
