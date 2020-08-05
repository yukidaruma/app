# Version 0.1.2 (2020-08-06)

## Bug fixes

* Make it possible to update iksm_session after expiration

## Other updates

* Update GitHub Actions to run on release branch push instead of tag
* Upload release APK to GitHub
* Update release.sh for better workflor with GitHub Actions  As we starting to let build AAB by GitHub Actions, we no longer need to build locally.    This commit also  * Renames release.sh to commit-release.sh  * No longer merge branch on successful build (5a5a618)
* Rename github-release.yml to release.yml----  style: Improve release notes readability


# Version 0.1.1 (2020-08-04)

## Feature updates

* Add "Share" button for "Salmon Stats" tab
* Implement load results from database on reaching the end of results

----

# Version 0.1.0 (2020-07-03)

## Feature updates

* Add support for multiple accounts
* Add release notes page

## Bug fixes

* Fix error when pressing "Continue" button multiple times in "Enter iksm_session Page"
