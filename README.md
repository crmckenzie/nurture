# Nurture

Welcome to your new gem! In this directory, you'll find the files you need to be able to package up your Ruby library into a gem. Put your Ruby code in the file `lib/nurture`. To experiment with that code, run `bin/console` for an interactive prompt.

TODO: Delete this and the text above, and describe your gem

## Installation


## Usage

```yaml

urls:
  - url: /manifests
    - get: retrieves manifests;
      notes: can use simple property filtering in the query string
             e.g., /manifests?status=ready&name=pr.345
- url: /manifests/:name
    - get: gets a  manifest by name
    - post: creates a new manifest
      notes: fails if manifest already exists with :name
    - put: updates a manifest
      notes: fails if manifest has been staged or released
    - delete: deletes a manifest
      notes: fails if manifest has been staged or released

  -url: /manifests/:name/ready
    - post: moves the manifest into ready status
      notes: application versions must be specific (:latest not allowed)
             artifacts must be ready for deployment (pinned in teamcity, in the prod folder in artifactory)
  
  -url: /manifests/:name/stage
    - post: moves the manifest into staged status
      notes: application versions must be specific (:latest not allowed)
             artifacts must be ready for deployment (pinned in teamcity, in the prod folder in artifactory)
  
  -url: /manifests/:name/release
    - post: moves the manifest into released status
      notes: application versions must be specific (:latest not allowed)
             artifacts must be ready for deployment (pinned in teamcity, in the prod folder in artifactory)
             application versions are written to prod
             manifest is detached from non-prod environments
  
  -url: /environments
    - get: retrieves environments
      notes: environments are retrieved from chef and merged with metadata found in Nurture
  
  -url: /environments/:name
    - get: gets a specific environment by name
    - put: used to attach one or more manifests to an environment

  -url: /environments/:name/:application_name
    - get: gets the version for a specific application


types:
  - name: Manifest
    fields:
    - name: the name of the manifest - retrieved from leankit
    - description: a description of the manifest
    - contents: a list of ApplicationVersions
    - status: development, ready, staged, or released
    - created_by: user who created the manifest
    - modified_by: user who last modified the manifest
    - readied_by: user who marked the manifest as ready
    - readied_date: date/time of promotion to ready
    - staged_by: user who promoted the manifest to staging
    - staged_date: date/time of promotion to staging
    - released_by: user who released the manifest to production
    - release_date: date/time of release to production
  - name: ApplicationVersion
    fields: 
    - name: the name of the application being updated
    - version: the version of the application (can be :latest in non-staging, non-prod environments)
    - branch: branch on which to find the application version
  - name: Environment
    fields:
    - name: the name of the environment
    - type: dev, staging, prod (only one prod environment is allowed)
    - manifests: array of manifest names. Only one is allowed in dev. 
                 Many are allowed in staging.
                 None are allowed in prod.



```


## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release` to create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

1. Fork it ( https://github.com/[my-github-username]/nurture/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
