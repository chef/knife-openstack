# Contributing to Chef's knife-openstack

We're glad you want to contribute to Chef's knife-openstack! The first step is the desire to improve the project.

## Getting in Contact with Us

If you're interested in contributing to Chef's knife-openstack or just have a question about one of one of them we'd love to chat. You can find us in #general on the [Chef Community Slack](https://community-slack.chef.io/).

## Submitting Issues

Not every contribution comes in the form of code. Submitting, confirming, and triaging issues is an important task for any project. At Chef we use GitHub to track all project issues.

## Contribution Process

We have a 3 step process for contributions:

1. Commit changes to a git branch, making sure to sign-off those changes for the [Developer Certificate of Origin](#developer-certification-of-origin-dco).
2. Create a GitHub Pull Request for your change, following the instructions in the pull request template.
3. Perform a [Code Review](#code-review-process) with the cookbook maintainers on the pull request.

### Code Review Process

Code review takes place in GitHub pull requests. See [this article](https://help.github.com/articles/about-pull-requests/) if you're not familiar with GitHub Pull Requests.

Once you open a pull request, cookbook maintainers will review your code using the built-in code review process in Github PRs. The process at this point is as follows:

1. A maintainer will review your code and merge it if no changes are necessary. Your change will be merged into the cookbooks's `master` branch and will be noted in the cookbook's `CHANGELOG.md` at the time of release.
2. If a maintainer has feedback or questions on your changes they they will set `request changes` in the review and provide an explanation.

### Developer Certification of Origin (DCO)

Licensing is very important to open source projects. It helps ensure the software continues to be available under the terms that the author desired.

Chef uses [the Apache 2.0 license](https://github.com/chef/chef/blob/master/LICENSE) to strike a balance between open contribution and allowing you to use the software however you would like to.

The license tells you what rights you have that are provided by the copyright holder. It is important that the contributor fully understands what rights they are licensing and agrees to them. Sometimes the copyright holder isn't the contributor, such as when the contributor is doing work on behalf of a company.

To make a good faith effort to ensure these criteria are met, Chef requires the Developer Certificate of Origin (DCO) process to be followed.

The DCO is an attestation attached to every contribution made by every developer. In the commit message of the contribution, the developer simply adds a Signed-off-by statement and thereby agrees to the DCO, which you can find below or at <http://developercertificate.org/>.

```
Developer's Certificate of Origin 1.1

By making a contribution to this project, I certify that:

(a) The contribution was created in whole or in part by me and I
    have the right to submit it under the open source license
    indicated in the file; or

(b) The contribution is based upon previous work that, to the
    best of my knowledge, is covered under an appropriate open
    source license and I have the right under that license to
    submit that work with modifications, whether created in whole
    or in part by me, under the same open source license (unless
    I am permitted to submit under a different license), as
    Indicated in the file; or

(c) The contribution was provided directly to me by some other
    person who certified (a), (b) or (c) and I have not modified
    it.

(d) I understand and agree that this project and the contribution
    are public and that a record of the contribution (including
    all personal information I submit with it, including my
    sign-off) is maintained indefinitely and may be redistributed
    consistent with this project or the open source license(s)
    involved.
```

For more information on the change see the Chef Blog post [Introducing Developer Certificate of Origin](https://blog.chef.io/2016/09/19/introducing-developer-certificate-of-origin/)

#### DCO Sign-Off Methods

The DCO requires a sign-off message in the following format appear on each commit in the pull request:

```
Signed-off-by: Julia Child <juliachild@chef.io>
```

The DCO text can either be manually added to your commit body, or you can add either **-s** or **--signoff** to your usual git commit commands. If you forget to add the sign-off you can also amend a previous commit with the sign-off by running **git commit --amend -s**. If you've pushed your changes to GitHub already you'll need to force push your branch after this with **git push -f**.

### Chef Obvious Fix Policy

Small contributions, such as fixing spelling errors, where the content is small enough to not be considered intellectual property, can be submitted without signing the contribution for the DCO.

As a rule of thumb, changes are obvious fixes if they do not introduce any new functionality or creative thinking. Assuming the change does not affect functionality, some common obvious fix examples include the following:

- Spelling / grammar fixes
- Typo correction, white space and formatting changes
- Comment clean up
- Bug fixes that change default return values or error codes stored in constants
- Adding logging messages or debugging output
- Changes to 'metadata' files like Gemfile, .gitignore, build scripts, etc.
- Moving source files from one directory or package to another

**Whenever you invoke the "obvious fix" rule, please say so in your commit message:**

```
------------------------------------------------------------------------
commit 370adb3f82d55d912b0cf9c1d1e99b132a8ed3b5
Author: Julia Child <juliachild@chef.io>
Date:   Wed Sep 18 11:44:40 2015 -0700

  Fix typo in the README.

  Obvious fix.

------------------------------------------------------------------------
```

## Using git

For collaboration purposes, it is best if you create a GitHub account and fork the repository to your own account. Once you do this you will be able to push your changes to your GitHub repository for others to see and use.

### Branches and Commits

You should submit your patch as a git branch named after the Github issue, such as GH-22\. This is called a _topic branch_ and allows users to associate a branch of code with the ticket.

It is a best practice to have your commit message have a _summary line_ that includes the ticket number, followed by an empty line and then a brief description of the commit. This also helps other contributors understand the purpose of changes to the code.

```text
    [GH-22] - platform_family and style

    * use platform_family for platform checking
    * update notifies syntax to "resource_type[resource_name]" instead of
      resources() lookup
    * GH-692 - delete config files dropped off by packages in conf.d
    * dropped debian 4 support because all other platforms have the same
      values, and it is older than "old stable" debian release
```

Remember that not all users use Chef in the same way or on the same operating systems as you, so it is helpful to be clear about your use case and change so they can understand it even when it doesn't apply to them.

### More information

Additional help with git is available on the [Community Contributions](https://docs.chef.io/community_contributions.html#use-git) page on the Chef Docs site.

## Contribution Do's and Don't's

Please do include tests for your contribution. If you need help, ask on the [chef-dev mailing list](https://discourse.chef.io/c/dev) or the [Chef Community Slack](https://community-slack.chef.io/). Not all platforms that a cookbook supports may be supported by Test Kitchen. Please provide evidence of testing your contribution if it isn't trivial so we don't have to duplicate effort in testing.

Please do indicate new platform (families) or platform versions in the commit message, and update the relevant ticket.

If a contribution adds new platforms or platform versions, indicate such in the body of the commit message(s), and update the relevant issues. When writing commit messages, it is helpful for others if you indicate the issue. For example: git commit -m '[ISSUE-1041] - Updated pool resource to correctly delete.'

Please do ensure that your changes do not break or modify behavior for other platforms supported by the cookbook. For example if your changes are for Debian, make sure that they do not break on CentOS.

Please do **not** modify the version number in the `metadata.rb`, a maintainer will select the appropriate version based on the release cycle information above.

Please do **not** update the `CHANGELOG.md` for a new version. Not all changes to a cookbook may be merged and released in the same versions. A maintainer will update the `CHANGELOG.md` when releasing a new version of the cookbook.

## Chef Community

Chef is made possible by a strong community of developers and system administrators. If you have any questions or if you would like to get involved in the Chef community you can check out:

- [Chef Mailing List](https://discourse.chef.io/)
- [Chef Community Slack](https://community-slack.chef.io/)

Also here are some additional pointers to some awesome Chef content:

- [Chef Docs](https://docs.chef.io/)
- [Learn Chef](https://learn.chef.io/)
- [Chef Website](https://www.chef.io/)
