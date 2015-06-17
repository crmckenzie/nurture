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
- [ ] rename application_versions to versions

### Manifest
- [ ] rename application_versions to versions

### Release
- [ ] rename application_versions to versions

### API
- [ ] rename application_versions to versions

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
- [x] does not create duplicate«» application versions
- [x] if version already exists, make sure manifest is appliedß

## POST /releases

- [x] manifests are required.
- [x] manifests cannot be already released
- [ ] manifest is removed from source environment
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

## GET /environments

- [x] should include manifest names

## GET /environments/:name

- [x] should include manifest names

## GET /environments/:name/application_versions

- [x] returns the list of application versions associated with the environment (all prod + modifications from manifests)
- [x] last release should be used when reporting current prod application versions

## GET /environments/:name/application_versions/:app_name

- [x] returns the application version for the environment.

## DELETE /applications/:name

- [ ] removes an application
- [ ] fails if the application has been released
- [ ] implies a need for archived applicatioÂns that are not returned from /applications by default

## GET /applications/:name/versions

- [x] returns the version history of an application

## GET /applications/:name/releases

- [x] release history for a given application (date, version)
