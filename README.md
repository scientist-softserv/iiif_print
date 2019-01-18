newspaper_works — Newspaper Works for Samvera
===================================================
Code:
[![Build Status](https://travis-ci.org/marriott-library/newspaper_works.svg?branch=master)](https://travis-ci.org/marriott-library/newspaper_works)

Docs:
[![Apache 2.0 License](http://img.shields.io/badge/APACHE2-license-blue.svg)](./LICENSE)
[![Contribution Guidelines](http://img.shields.io/badge/CONTRIBUTING-Guidelines-blue.svg)](./.github/CONTRIBUTING.md)

Jump in: [![Slack Status](http://slack.samvera.org/badge.svg)](http://slack.samvera.org/)

<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->
# Table of Contents
- [Introduction](#introduction)
  - [Documentation](#documentation)
- [Overview](#overview)
	- [Purpose, Use, and Aims](#purpose-use-and-aims)
	- [Development Status](#development-status)
	- [Requirements](#requirements)
	  - [Newspaper Works Dependencies](#newspaper-works-dependencies)
	- [PCDM metadata Model](#Newspapers-PCDM-metadata-model)
- [Installation/Testing](#installationtesting)
	- [Extending, Using](#extending-using)
	- [Basic Model Use (console)](#basic-model-use-console)
	- [Application/Site Specific Configuration](#applicationsite-specific-configuration)
	- [Development and Testing Setup](#development-and-testing-setup)
- [Credits](#credits)
	- [Sponsoring Organizations](#sponsoring-organizations)
	- [Contributors and Project Team](#contributors-and-project-team)
	- [More Information / Contact](#more-information-contact)

<!-- /TOC -->

# Introduction
The Newspapers in Samvera is an IMLS grant funded project to develop newspaper specific functionality for the [Samvera](http://samvera.org/) Hyrax framework.

## Documentation

[Newspapers_Works Wiki](https://github.com/marriott-library/newspaper_works/wiki)

# Overview
The Newspaper Works gem provides work type models and administrative
functionality for Hyrax-based Samvera applications in the space
of scanned newspaper media.  This gem can be included in a
Digital Asset Management application based on Hyrax 2.x.

## Purpose, Use, and Aims
This gem, while not a stand-alone application, can be integrated into an
application based on Hyrax 2.x easily to support a variety of cases for
management, ingest, and archiving of primarily scanned (historic) newspaper archives.

## Development Status

This gem is currently under development. The development team is actively working on this project and expects to have an alpha release of the application later this Summer.

## Requirements

  * [Ruby](https://rubyonrails.org/) 2.4+
  * [Rails](https://rubyonrails.org/) 5.0.6
  * [Bundler](http://bundler.io/)
  * [Hyrax](https://github.com/samvera/hyrax) 2.2.0
    - ..._and various [Samvera dependencies](https://github.com/samvera/hyrax#getting-started) that entails_.
  * A Hyrax-based Rails application.
    * newspaper_works is a gem/engine that can extend your application.

## Newspaper_Works Dependencies

  * [FITS](https://projects.iq.harvard.edu/fits/home)
  * [Tesseract-ocr](https://github.com/tesseract-ocr/)
  * [LibreOffice](https://www.libreoffice.org/)
  * [ghostscript](https://www.ghostscript.com/)
  * [poppler-utils](https://poppler.freedesktop.org/)
  * [GraphicsMagick](http://www.graphicsmagick.org/)
  * [libcurl3](https://packages.ubuntu.com/search?keywords=libcurl3)


## Newspapers PCDM metadata model

This model describes digitized newspaper content modeled using the PCDM ontology, and is intended to inform the development of RDF-based models for all types of newspaper content objects (titles, containers, issues, pages, articles, files), such as would be used in Samvera- or Islandora-based digital asset management applications.

This model was greatly informed by earlier efforts from National Library of Wales and University of Maryland, as well as discussions of the Samvera Newspapers Interest Group. This is essentially an attempt to reconcile these efforts and express them as a formal PCDM profile.

[Detailed metadata model documents](https://wiki.duraspace.org/display/samvera/PCDM+metadata+model+for+Newspapers)

# Installation/Testing
Integrating Newspaper_Works in your application.
Your Hyrax 2.2.0 based application can extend and utilize `newspaper_works`

## Extending, Using

* Add `gem 'newspaper_works', :git => 'https://github.com/marriott-library/newspaper_works.git'`
	to your Gemfile.
* Run `bundle install`

### Ingest, Application Interface

_See [wiki](https://github.com/marriott-library/newspaper_works/wiki)_.

### Application/Site Specific Configuration


## Basic Model Use (console)

_More here soon!_

## Application/Site Specific Configuration
* In order to use some fields in forms, you will want to make sure you
have a [username for Geonames](http://www.geonames.org/login),
and configure that username in the
`config.geonames_username` value in `config/intitializers/hyrax.rb` of your app.

- This will help fields such as "Place of Publication" provide autocomplete using the Geonames service/vocabulary.

  * NewspaperWorks requires that your application's `config/initializers/hyrax.rb`
    be edited to make uploads optional for (all) work types, by setting
    `config.work_requires_files = false`.
    
  * NewspaperWorks expects that your application's `config/initializers/hyrax.rb`
    be edited to enable a IIIF viewer, by setting
    `config.iiif_image_server = true`.    

  * NewspaperWorks overrides Hyrax's default `:after_create_fileset` event
    handler, in order to attach pre-existing derivatives in some ingest
    use cases.  The file attachment adapters for NewspaperWorks use this
    callback to allow programmatic assignment of pre-existing derivative
    files before the primary file's file set has been created for a new
    work.  The callback ensures that derivative files are attached,
    stored using Hyrax file/path naming conventions, once the file set
    has been created.  Because the Hyrax callback registry only allows single
    subscribers to any event, application developers who overwrite
    this handler, or integrate other gems that do likewise, must take care
    to create a custom composition that ensures all work and queued jobs
    desired run after this object lifecycle event.

## Development and Testing with Vagrant
* clone samvera-vagrant

`
git clone https://github.com/marriott-library/samvera-vagrant.git
`

* Start vagrant box provisioning: `cd samvera-vagrant && vagrant up`

* Shell into vagrant box **three times** `vagrant ssh`

* First shell (start fcrepo_wrapper)
`cd /home/ubuntu/newspaper_works && fcrepo_wrapper --config config/fcrepo_wrapper_test.yml`

* Second shell (start solr_wrapper)
`cd /home/ubuntu/newspaper_works && solr_wrapper --config config/solr_wrapper_test.yml`
* Third shell testing and development

* Run spec tests
`cd /home/ubuntu/newspaper_works && rake spec`

* Run rails console
`cd /home/ubuntu/newspaper_works && rails s`

## Development and Testing Setup
* clone `newspaper_works`:
  - `git clone https://github.com/marriott-library/newspaper_works.git`
* Install Gem and dependencies:
  - `bundle install`
* Generate internal testing application
  - `rake engine_cart:generate`
* Each in a distinct terminal session, run Solr and Fedora Commons Wrappers:
  - `solr_wrapper --config config/solr_wrapper_test.yml`
  - `fcrepo_wrapper --config config/fcrepo_wrapper_test.yml`
* Now you can either:
  - Run tests via `rake spec` in the root of the `newspaper_works` gem.
  - Run an interactive Rails console in the generated testing app:
    - `rails`
* For development, you may want to include a clone of `newspaper_works`
  in your app's Gemfile, either via `github:` or by `path:` in a local
  Gemfile used only for local development of your app.


# Credits
## Sponsoring Organizations

This gem is part of a project developed in a collaboration between
[The University of Utah](https://www.utah.edu/), [J. Willard Marriott Library](https://www.lib.utah.edu/ß) and
[Boston Public Library](https://www.bpl.org/), as part of a "Newspapers in Samvera" project
grant funded by the [Institute for Museum and Library Services](https:///imls.gov).

The development team is grateful for input, collaboration, and support
we receive from the Samvera Community, related working groups,
and our project's advisory board.

## Contributors and Project Team

  * [Eben English](https://github.com/ebenenglish) (Boston Public Library)
  * [Brian McBride](https://github.com/brianmcbride) (University of Utah)
  * [Jacob Reed](https://github.com/JacobR) (University of Utah)
  * [Sean Upton](https://github.com/seanupton) (University of Utah)
  * Harish Maringhanti (University of Utah)

## More Information
 * [Samvera Newspapers Group](https://wiki.duraspace.org/display/samvera/Samvera+Newspapers+Interest+Group) - The Samvera Newspapers Interest groups meets on the first Thursday of every month to discuss the Samvera newspapers project and general newspaper topics.
 * [Samvera Community](http://samvera.org/) - Samvera™ is the new name for Hydra. Samvera is a grass-roots, open source community creating best in class digital asset management solutions for Libraries, Archives, Museums and others.
 * [Samvera on Github](https://github.com/samvera/) - Officially supported and maintained Samvera gems and applications for Digital Repository management
 * [Newspapers in Samvera IMLS Grant (formerly Hydra)](https://www.imls.gov/grants/awarded/lg-70-17-0043-17) - The official grant award for the project.

## Contact
  * Contact any contributors above by email, or ping us on
    [Samvera Community Slack channel(s).](http://slack.samvera.org/)


![Institute of Museum and Library Services Logo](https://imls.gov/sites/default/files/logo.png)
![University of Utah Logo](http://www.utah.edu/_images/imagine_u.png)
![Boston Public Library Logo](https://cor-liv-cdn-static.bibliocommons.com/images/MA-BOSTON-BRANCH/logo.png?1528788420451)
