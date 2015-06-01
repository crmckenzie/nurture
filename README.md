# Nurture API

## /manifests

### GET

Returns a list of manifests.

Can perform simple queries by field=value in query string

### POST

    {
      	name: {string: required},
      	description: {string: optional},
      	application_versions: {
	          <application_name1>: version,
	          <application_name2>: version
        }
    }

### PUT
    {
	      name: {string: required},
	      description: {string: optional},
	      application_versions: {
	          <application_name1>: version,
	          <application_name2>: version
	      }
    }

### DELETE
    {
    	name: {string: required}
    }


## /manifests/:name

### GET

Returns an individual manifest by name.



## /environments

### GET

returns a list of environments

### POST
    {
    	name: {string: required}
    }

### DELETE
    {
    	name: {string: required}
    }

## /environments/:name

### GET

returns a single environment by name

## /environment/:name/application_versions

### GET

Returns the application versions associated with an environment.

## /environments/:name/application_versions/:name

### GET

Returns the application version by name in the given environment.




## TODO

Still need apis

* declaring a manifest ready for staging
* promoting a manifest to a staging environment
* promoting a manifest to a production environment
* rolling back a manifest from production
* rolling back a manifest from staging
* rolling back a manifest from ready

## Comments

* Suggest /releases for the actual release process
	* /releases/applications/:name - get application release history
* Not sure how to noun-ize "staging"
