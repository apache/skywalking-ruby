# Apache SkyWalking Ruby Release Guide

This documentation guides the release manager to release the SkyWalking Ruby in the Apache Way, and also helps people to check the release for voting.

## Prerequisites

1. Close (if finished, or move to next milestone otherwise) all issues in the current milestone from [skywalking-ruby](https://github.com/apache/skywalking-ruby/milestones) and [skywalking](https://github.com/apache/skywalking/milestones), create a new milestone for the next release.
1. Update [CHANGELOG.md](../../../CHANGELOG.md) and `version` in [Version.rb](../../../lib/skywalking/version.rb).


## Add your GPG public key to Apache svn

1. Upload your GPG public key to a public GPG site, such as [MIT's site](http://pgp.mit.edu:11371/).

1. Log in [id.apache.org](https://id.apache.org/) and submit your key fingerprint.

1. Add your GPG public key into [SkyWalking GPG KEYS](https://dist.apache.org/repos/dist/release/skywalking/KEYS) file, **you can do this only if you are a PMC member**.  You can ask a PMC member for help. **DO NOT override the existed `KEYS` file content, only append your key at the end of the file.**


## Build and sign the source code package

```shell
export VERSION=<the version to release>

git clone --recurse-submodules git@github.com:apache/skywalking-ruby && cd skywalking-ruby
git tag -a "v$VERSION" -m "Release Apache SkyWalking-Ruby $VERSION"
git push --tags
make release
```

## Upload to Apache svn

```bash
svn co https://dist.apache.org/repos/dist/dev/skywalking/ruby/ release/skywalking/ruby
mkdir -p release/skywalking/ruby/"$VERSION"
cp skywalking-ruby/skywalking*.tgz release/skywalking/ruby/"$VERSION"
cp skywalking-ruby/skywalking*.tgz.asc release/skywalking/ruby/"$VERSION"
cp skywalking-ruby/skywalking*.tgz.sha512 release/skywalking/ruby/"$VERSION"

cd release/skywalking/ruby && svn add $VERSION && svn commit -m "Draft Apache SkyWalking-Ruby release $VERSION"
```

## Call for vote in dev@ mailing list

First, generate a sha512sum for the source code package generated in last step:

```shell
sha512sum release/skywalking/ruby/"$VERSION"/skywalking-ruby-src-"$VERSION".tgz
```

Call for vote in `dev@skywalking.apache.org`.

```text
Subject: [VOTE] Release Apache SkyWalking Ruby version $VERSION

Content:

Hi the SkyWalking Community:
This is a call for vote to release Apache SkyWalking Ruby version $VERSION.

We welcome any comments you may have, and will take all feedback into
account if a quality vote is called for this build.

Release notes:

 * https://github.com/apache/skywalking-ruby/blob/v$VERSION/CHANGELOG.md

Release Candidate:

 * https://dist.apache.org/repos/dist/dev/skywalking/ruby/$VERSION
 * sha512 checksums
   - sha512xxxxyyyzzz skywalking-ruby-src-x.x.x.tgz

Release Tag :

 * (Git Tag) v$VERSION

Release Commit Hash :

 * https://github.com/apache/skywalking-ruby/tree/<Git Commit Hash>

Keys to verify the Release Candidate :

 * https://dist.apache.org/repos/dist/release/skywalking/KEYS

Guide to build the release from source :

 * https://github.com/apache/skywalking-ruby/blob/main/CONTRIBUTING.md#compiling-and-building

A vote regarding the quality of this test build will be initiated
within the next couple of days.
```

## Vote Check

All PMC members and committers should check these before voting +1:

1. Features test.
1. All artifacts in staging repository are published with `.asc`, `.md5`, and `sha` files.
1. Source codes and distribution packages (`skywalking-ruby-src-$VERSION.tgz`)
are in `https://dist.apache.org/repos/dist/dev/skywalking/ruby/$VERSION` with `.asc`, `.sha512`.
1. `LICENSE` and `NOTICE` are in source codes and distribution package.
1. Check `shasum -c skywalking-ruby-src-$VERSION.tgz.sha512`.
1. Check `gpg --verify skywalking-ruby-src-$VERSION.tgz.asc skywalking-ruby-src-$VERSION.tgz`.
1. Build distribution from source code package by following this [the build guide](#build-and-sign-the-source-code-package).
1. Licenses check, `make license`.

Vote result should follow these:

1. PMC vote is +1 binding, all others is +1 no binding.

1. Within 72 hours, you get at least 3 (+1 binding), and have more +1 than -1. Vote pass.

1. **Send the closing vote mail to announce the result**.  When count the binding and no binding votes, please list the names of voters. An example like this:

   ```
   [RESULT][VOTE] Release Apache SkyWalking Ruby version $VERSION

   72+ hours passed, we’ve got ($NUMBER) +1 bindings (and ... +1 non-bindings):

   (list names)
   +1 bindings:
   xxx
   ...

   +1 non-bindings:
   xxx
   ...

   Thank you for voting, I’ll continue the release process.
   ```

## Publish release

1. Move source codes tar balls and distributions to `https://dist.apache.org/repos/dist/release/skywalking/`, **you can do this only if you are a PMC member**.

    ```shell
    svn mv https://dist.apache.org/repos/dist/dev/skywalking/ruby/"$VERSION" https://dist.apache.org/repos/dist/release/skywalking/ruby/"$VERSION"
    ```

1. Refer to the previous [PR](https://github.com/apache/skywalking-website/pull/190), update news and links on the website. There are several files need to modify.

1. Update [Github release page](https://github.com/apache/skywalking-ruby/releases), follow the previous convention.

1. Publish to rubygems.org, this is optional for Apache releases, but we usually want to do this to let users use it conveniently.

  ```shell
  gem build skywalking.gemspec
  gem push skywalking.gemspec
  ```

**NOTE**: please double check before publishing to rubygems.org, it's difficult to unpublish and republish the module at the moment.

1. Send ANNOUNCE email to `dev@skywalking.apache.org` and `announce@apache.org`, the sender should use his/her Apache email account.

    ```
    Subject: [ANNOUNCEMENT] Apache SkyWalking Ruby $VERSION Released

    Content:

    Hi the SkyWalking Community

    On behalf of the SkyWalking Team, I’m glad to announce that SkyWalking Ruby $VERSION is now released.

    SkyWalking Ruby: The Ruby Agent for Apache SkyWalking, which provides the native tracing abilities for Ruby backend project.

    SkyWalking: APM (application performance monitor) tool for distributed systems, especially designed for microservices, cloud native and container-based (Docker, Kubernetes, Mesos) architectures.

    Download Links: http://skywalking.apache.org/downloads/

    Release Notes : https://github.com/apache/skywalking-ruby/blob/v$VERSION/CHANGELOG.md

    Website: http://skywalking.apache.org/

    SkyWalking Ruby Resources:
    Issue: https://github.com/apache/skywalking/issues

    - Mailing list: dev@skywalking.apache.org
    - Documents: https://github.com/apache/skywalking-ruby/blob/v$VERSION/README.md

    The Apache SkyWalking Team
   ```
