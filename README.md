NewspaperWorks
===================================================
Code:
[![Build Status](https://travis-ci.org/samvera-labs/newspaper_works.svg?branch=master)](https://travis-ci.org/samvera-labs/newspaper_works) [![Coverage Status](https://coveralls.io/repos/github/samvera-labs/newspaper_works/badge.svg?branch=master)](https://coveralls.io/github/samvera-labs/newspaper_works?branch=master)

Docs:
[![Apache 2.0 License](http://img.shields.io/badge/APACHE2-license-blue.svg)](./LICENSE)
[![Contribution Guidelines](http://img.shields.io/badge/CONTRIBUTING-Guidelines-blue.svg)](./.github/CONTRIBUTING.md)

Jump in: [![Slack Status](http://slack.samvera.org/badge.svg)](http://slack.samvera.org/)

<!-- TOC -->

- [Overview](#overview)
  - [Documentation](#documentation)
  - [Requirements](#requirements)
  - [Dependencies](#dependencies)
- [Installation](#installation)
  - [Application/Site Specific Configuration](#applicationsite-specific-configuration)
    - [Config changes made by the installer:](#config-changes-made-by-the-installer)
    - [Configuration changes you should make after running the installer](#configuration-changes-you-should-make-after-running-the-installer)
- [Ingesting Content](#ingesting-content)
- [Developing, Testing, and Contributing](#developing-testing-and-contributing)
  - [Contributing](#contributing)
- [Acknowledgements](#acknowledgements)
  - [Sponsoring Organizations](#sponsoring-organizations)
  - [More Information](#more-information)
  - [Contact](#contact)

<!-- /TOC -->

# Overview
NewspaperWorks is a gem (Rails "engine") for [Hyrax](https://hyrax.samvera.org/) -based digital repository applications to support ingest, management, and display of digitzed newspaper content.

NewspaperWorks is not a stand-alone application. It is designed to be integrated into a new or existing Hyrax (2.5.x) application, providing content models, ingest workflows, and feature-rich UX for newspaper repository use-cases.

NewspaperWorks supports:
* models for Title, Issue, Page, and Article
* batch ingest via command line
* OCR and ALTO creation
* newspaper-specific metadata fields
* full-text search
* calendar-based issue browsing
* advanced search
* OCR keyword match highlighting
* viewer with page navigation and deep zooming

A complete list of features can be found [here](https://github.com/samvera-labs/newspaper_works/wiki/Features-List).

## Documentation
A set of helpful documents to help you learn more and deploy NewspaperWorks can be found on the [Project Wiki](https://github.com/samvera-labs/newspaper_works/wiki), including a PCDM model diagram, metadata schema, batch ingest instructions, and more details on installing, developing, and testing the code.

## Requirements

  * [Ruby](https://rubyonrails.org/) >=2.4
  * [Rails](https://rubyonrails.org/) ~>5.1
  * [Bundler](http://bundler.io/)
  * [Hyrax](https://github.com/samvera/hyrax) ~>2.5
    - ..._and various [Samvera dependencies](https://github.com/samvera/hyrax#getting-started) that entails_.
  * A Hyrax-based Rails application

## Dependencies

  * [FITS](https://projects.iq.harvard.edu/fits/home)
  * [Tesseract-ocr](https://github.com/tesseract-ocr/)
  * [LibreOffice](https://www.libreoffice.org/)
  * [ghostscript](https://www.ghostscript.com/)
  * [poppler-utils](https://poppler.freedesktop.org/)
  * [ImageMagick](https://github.com/ImageMagick/ImageMagick6)
    - _ImageMagick policy XML may need to be more permissive in both resources and source media types allowed.  See template [policy.xml](config/vendor/imagemagick-6-policy.xml)._
  * [libcurl3](https://packages.ubuntu.com/search?keywords=libcurl3)

See the [wiki](https://github.com/samvera-labs/newspaper_works/wiki/Installing,-Developing,-and-Testing) for more details on how to install and configure dependencies.

# Installation
NewspaperWorks easily integrates with your Hyrax 2.5.x applications.

* Add `gem 'newspaper_works'` to your Gemfile.
* Run `bundle install`
* Run `rails generate newspaper_works:generate`
* Set config options as indicated below...

## Application/Site Specific Configuration

### Config changes made by the installer:
* In `app/controllers/catalog_controller.rb`, the `config.search_builder_class` is set to a new `CustomSearchBuiler` to support newspapers search features.
* Additional facet fields for newspaper metadata are added to `app/controllers/catalog_controller.rb`.
* Newspaper resource types added to `config/authorities/resource_types.yml`.

(It may be helpful to run `git diff` after installation to see all the changes made by the installer.)

### Configuration changes you should make after running the installer:

#### in config/intitializers/hyrax.rb:
* set `config.geonames_username`
  * Enables geolocation tagging of content
  * [how to create a Geonames username](http://www.geonames.org/login)
* set `config.work_requires_files = false`
* set `config.iiif_image_server = true`
* set `config.fits_path = /location/of/fits.sh`

#### in config/environments/production.rb:

* set `config.public_file_server.enabled = true`

# Ingesting Content

NewspaperWorks supports a range of different ingest workflows:
* single-item ingest via the UI
* batch ingest of [NDNP materials](https://github.com/samvera-labs/newspaper_works/wiki/NDNP-Batch-Ingest-Guide) (page-level digitization) via command line
* batch ingest of [PDF issues](https://github.com/samvera-labs/newspaper_works/wiki/PDF-Batch-Ingest-Guide) via command line
* batch ingest of [TIFF or JP2 master files](https://github.com/samvera-labs/newspaper_works/wiki/TIFF-or-JP2-Batch-Ingest-Guide) via command line

The ingest process creates a full complement of derivatives for each Page object, including:
* TIFF
* JP2
* PDF
* OCR text
* word-coordinate JSON

For more information on derivatives, see the [wiki](https://github.com/samvera-labs/newspaper_works/wiki/Image-Format-and-Derivative-Notes).

# Developing, Testing, and Contributing

Detailed information regarding development and testing environments setup and configuration can be found [here](https://github.com/samvera-labs/newspaper_works/wiki/Installing,-Developing,-and-Testing)

A Vagrant VM is available for users and developers to quickly and easily deploy the latest NewspaperWorks codebase using Vagrant and VirtualBox. See [samvera-newspapers-vagrant](https://github.com/samvera-labs/samvera-newspapers-vagrant) for more.

Additionally, the [NewspaperWorks Demo Site](https://newspaperworks.digitalnewspapers.org/) is available for those interested in testing out NewspaperWorks as deployed in a vanilla Hyrax application. (**NOTE:** The demo site may not be running the latest release of NewspaperWorks.)

## Contributing

We encourage anyone who is interested in newspapers and Samvera to contribute to this project. [How can I contribute?](https://github.com/samvera/hyrax/blob/master/.github/CONTRIBUTING.md)

# Acknowledgements

## Sponsoring Organizations

This gem is part of a project developed in a collaboration between [The University of Utah](https://www.utah.edu/), [J. Willard Marriott Library](https://www.lib.utah.edu/) and [Boston Public Library](https://www.bpl.org/), as part of a "Newspapers in Samvera" project grant funded by the [Institute for Museum and Library Services](https:///imls.gov).

The development team is grateful for input, collaboration, and support we receive from the Samvera Community, related working groups, and our project's advisory board.

## More Information
 * [Samvera Newspapers Group](https://wiki.duraspace.org/display/samvera/Samvera+Newspapers+Interest+Group) - The Samvera Newspapers Interest groups meets on the first Thursday of every month to discuss the Samvera newspapers project and general newspaper topics.
 * [Newspapers in Samvera IMLS Grant (formerly Hydra)](https://www.imls.gov/grants/awarded/lg-70-17-0043-17) - The official grant award for the project.
 * [National Digital Newspapers Program NDNP](https://www.loc.gov/ndnp/)

## Contact
 Contact any contributors above by email, or ping us on [Samvera Community Slack channel(s)](http://slack.samvera.org/)

![Institute of Museum and Library Services Logo](https://imls.gov/sites/default/files/logo.png)

![University of Utah Logo](http://www.utah.edu/_images/imagine_u.png)

![Boston Public Library Logo](https://cor-liv-cdn-static.bibliocommons.com/images/MA-BOSTON-BRANCH/logo.png?1528788420451)

This software has been developed by and is brought to you by the Samvera community.  Learn more at the
[Samvera website](http://samvera.org/).

![Samvera Logo](https://wiki.duraspace.org/download/thumbnails/87459292/samvera-fall-font2-200w.png?version=1&modificationDate=1498550535816&api=v2)
