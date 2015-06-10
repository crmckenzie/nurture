# TODO

- [ ] implement a working swagger ui
- [ ] normalize errors

    {
      :field_name => 'message'
    }

## Models

### Application

- [x] create add_version method
    - should create new version if not exists
- [x] refactor POST /manifests and PUT /manifests/:name to use the new method


## POST /applications

- [x] name is required
- [x] name must be unique

## POST /manifests

- [x] name is required
- [x] name must be unique
- [x] application versions must be unique
- [x] normalize error messages
  - [x] application versions

## PUT /manifests

- [x] application versions are not updated if they are not given
- [x] at least one application version is required if they are given
- [x] applications must exist
- [x] application versions can be created dynamically
- [x] does not create duplicate application versions

## POST /releases

- [x] manifests are required.
- [x] manifests cannot be already released
- [ ] manifest is removed for source environment
- [x] manifest should be associated to the prod environment
  - [x] merges application versions into a release
  - [x] merges previously released versions of other applications into the release
versions
- [x] PUT is not allowed

## GET /releases

- [ ] recent releases and the application versions that were a part of them

## GET /releases/:id

- [x] release with the given id

## POST /environments

- [ ] should environment disallow duplicate application versions across manifests?

## PUT /environments/:name

- [ ] should environment disallow duplicate application versions across manifests?

## GET /environments/:name/application_versions

- [ ] returns the list of application versions associated with the environment (all prod + modifications from manifests)
- [ ] last release should be used when reporting current prod application versions

## GET /environments/:name/manifests

- [ ] get list of manifests associated with the environment

## DELETE /applications/:name

- [ ] removes an application (done)
- [ ] fails if the application has been released
- [ ] implies a need for archived applicatioÂns that are not returned from /applications by default


## GET /applications/:name/versions

- [ ] returns the version history of an application

## GET /applications/:name/releases

- [ ] release history for a given application

## GET /applications/:name/manifests

- [ ] returns a list of manifests associated with the application
