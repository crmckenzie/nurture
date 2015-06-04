# Nurture API

Provides an api spec and a sample implementation for a staged release management process.

[Swagger Docs](swagger.yml)

## TODO

- implement a working swagger ui

### POST /releases

#### data
    ['manifest-name-1', 'manifest-name-2']

#### effect

- locks manifests for editing
- merges application versions into the prod environment

### GET /releases

recent releases and the application versions that were a part of them

### GET /releases/:id

release with the given id



### GET /applications

returns all applications

### POST /applications

creates a new application

#### data

    {
      "name": "app 1",
      "description" : "lorem ipsum",
      "type": "web service",
      "platform" : "Windows Server",
      "tags" : ["tag1", "tag2", "tag3", "tag4"]
    }

### GET /application/:name

returns an application

### PUT /application/:name

#### data

    {
      "description" : "lorem ipsum",
      "type": "web service",
      "platform" : "Windows Server",
      "tags" : ["tag1", "tag2", "tag3", "tag4"]
    }

### DELETE /applications/:name

removes an application

- fails if the application has been released
- implies a need for archived applications that are not returned from /applications by default


### GET /application/:name/versions

returns the version history of an application

### GET /applications/:name/releases

release history for a given application

### GET /application/:name/manifests

returns a list of manifests associated with the application


### GET /environments/:name/application_versions

returns the list of application versions associated with the environment (all prod + modifications from manifests)
