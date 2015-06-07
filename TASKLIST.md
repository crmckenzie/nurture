# TODO

- [ ] implement a working swagger ui
- [ ] normalize errors

    {
      :field_name => 'message'
    }
    
## POST /applications

- [ ] name is required
- [ ] name must be unique

## POST /manifests

- [ ] name is required
- [x] name must be unique
- [x] application versions must be unique

## PUT /manifests

- [ ] at least one application version is required.
- [ ] applications must exist
- [ ] application versions can be created dynamically
- [ ] does not create duplicate application versions

## POST /releases

- [ ] manifests are required.
- [ ] manifests cannot be already released
- [ ] merges application versions into the prod environment
- [ ] PUT is not allowed


## GET /releases

- [ ] recent releases and the application versions that were a part of them

## GET /releases/:id

- [ ] release with the given id

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


## GET /environments/:name/application_versions

- [ ] returns the list of application versions associated with the environment (all prod + modifications from manifests)
