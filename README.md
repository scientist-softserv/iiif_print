Newspaper Works for Samvera
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
  - [Wiki](https://github.com/marriott-library/newspaper_works/wiki)
  - [Features Matrix](https://github.com/marriott-library/newspaper_works/wiki/Features-Matrix)
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
We are currently working on adding and updating documentation on our [Project Wiki](https://github.com/marriott-library/newspaper_works/wiki)

# Overview
The Newspaper Works gem provides work type models and administrative functionality for Hyrax-based Samvera applications in the space of scanned newspaper media.  This gem can be included in a Digital Asset Management application based on Hyrax 2.5.1

## Purpose, Use, and Aims
This gem, while not a stand-alone application, can be integrated into an application based on Hyrax 2.5 easily to support a variety of cases for management, ingest, and archiving of primarily scanned (historic) newspaper archives.

## Development Status
This gem is currently under development. The development team is actively working on this project and is updating the codebase nightly. We are targeting an initial 1.0 release for June 2019.

A public testing site is available for those interested in testing out the newspaper_works gem. [Newspaper Works Demo Site](https://newspaperworks.digitalnewspapers.org/) **NOTE:** The demo site may not be running the latest release of Newspapers_Works.

## Requirements

  * [Ruby](https://rubyonrails.org/) >=2.4
  * [Rails](https://rubyonrails.org/) 5.1.7
  * [Bundler](http://bundler.io/)
  * [Hyrax](https://github.com/samvera/hyrax) 2.5.1
    - ..._and various [Samvera dependencies](https://github.com/samvera/hyrax#getting-started) that entails_.
  * A Hyrax-based Rails application.
    * newspaper_works is a gem/engine that can extend your application.

## Newspaper_works Dependencies

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

# Installing, Developing, and Testing
Newspaper_works easily integrates with your Hyrax 2.5.1 applications.

## Extending and Using

* Add `gem 'newspaper_works', :git => 'https://github.com/marriott-library/newspaper_works.git'` to your Gemfile.
* Run `bundle install`
* Run `rails generate newspaper_works:generate`

### Ingest, Application Interface

_See [wiki](https://github.com/marriott-library/newspaper_works/wiki)_.

## Basic Model Use (console)

_More here soon!_

## Application/Site Specific Configuration

#### Config changes made by the installer:
* In `app/controllers/catalog_controller.rb`, the `config.search_builder_class` is set to a new `CustomSearchBuiler` to support newspapers search features
* Additional facet fields for newspaper metadata are added to `app/controllers/catalog_controller.rb`
* Newspaper resource types added to `config/authorities/resource_types.yml`

(It may be helpful to run `git diff` after installation to see all the changes made by the installer.)

#### Config changes you should make after running the installer:
* In order to use some fields in forms, you will want to make sure you
have a [username for Geonames](http://www.geonames.org/login),
and configure that username in the
`config.geonames_username` value in `config/intitializers/hyrax.rb` of your app.
  * This will help fields such as "Place of Publication" provide autocomplete using the Geonames service/vocabulary.
* NewspaperWorks requires that your application's `config/initializers/hyrax.rb` be edited to make uploads optional for (all) work types, by setting `config.work_requires_files = false`.
* NewspaperWorks expects that your application's `config/initializers/hyrax.rb` be edited to enable a IIIF viewer, by setting` config.iiif_image_server = true`.    
* NewspaperWorks expects that your application's `config/initializers/hyrax.rb` be edited to set the FITS path, by setting `config.fits_path = /location/of/fits.sh`
* NewspaperWorks expects that your application's `config/environments/production.rb` be edited to set file server to public, by setting `config.public_file_server.enabled = true`
* NewspaperWorks overrides Hyrax's default `:after_create_fileset` event handler, in order to attach pre-existing derivatives in some ingest use cases.  The file attachment adapters for NewspaperWorks use this callback to allow programmatic assignment of pre-existing derivative files before the primary file's file set has been created for a new work.  The callback ensures that derivative files are attached, stored using Hyrax file/path naming conventions, once the file set has been created.  Because the Hyrax callback registry only allows single subscribers to any event, application developers who overwrite this handler, or integrate other gems that do likewise, must take care to create a custom composition that ensures all work and queued jobs desired run after this object lifecycle event.

## Development and Testing with Vagrant

Additional information regarding development and testing environments setup and configuration can be found [here](https://github.com/marriott-library/newspaper_works/wiki/Development-and-Testing)

### Host System Requirements (install these before proceeding)

* [Vagrant](https://www.vagrantup.com/) version 1.8.3+
* [VirtualBox](https://www.virtualbox.org/) version 5.1.38+

### Test Environment Setup (provisioning of virtual machine)

1. Clone newspaper works samvera-newspapers-vagrant `git clone https://github.com/marriott-library/samvera-newspapers-vagrant.git`
2. Change the directory to the repository `cd samvera-newspapers-vagrant`
3. Provision vagrant box by running `vagrant up`
4. Shell into the machine with `vagrant ssh` or `ssh -p 2222 vagrant@localhost`

### Using/testing the Newspaper_works application with Vagrant
* Ensure you're in the samvera-newspapers-vagrant directory
* Start vagrant box provisioning (incase you have not provisioned the virtual machine)
  - `vagrant up`
* Shell into vagrant box **three times**
  - `vagrant ssh`
* First shell (start fcrepo_wrapper)
  - `cd /home/vagrant/newspaper_works fcrepo_wrapper --config config/fcrepo_wrapper_test.yml`
* Second shell (start solr_wrapper)
  - `cd /home/vagrant/newspaper_works solr_wrapper --config config/solr_wrapper_test.yml`
* Third shell testing and development
* Run spec tests
  - `cd /home/vagrant/newspaper_works rake spec`
* Run rails console
  - `cd /home/vagrant/newspaper_works rails s`

## Development and testing setup

* clone newspaper_works:
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
* For development, you may want to include a clone of `newspaper_works` in your app's Gemfile, either via `github:` or by `path:` in a local Gemfile used only for local development of your app.

# Acknowledgements
## Sponsoring Organizations

This gem is part of a project developed in a collaboration between
[The University of Utah](https://www.utah.edu/), [J. Willard Marriott Library](https://www.lib.utah.edu/ß) and
[Boston Public Library](https://www.bpl.org/), as part of a "Newspapers in Samvera" project
grant funded by the [Institute for Museum and Library Services](https:///imls.gov).

The development team is grateful for input, collaboration, and support we receive from the Samvera Community, related working groups, and our project's advisory board.

## Contributors and Project Team

  * [Eben English](https://github.com/ebenenglish) (Boston Public Library)
  * [Brian McBride](https://github.com/brianmcbride) (University of Utah)
  * [Jacob Reed](https://github.com/JacobR) (University of Utah)
  * [Sean Upton](https://github.com/seanupton) (University of Utah)
  * Harish Maringanti (University of Utah)

## More Information
 * [Samvera Newspapers Group](https://wiki.duraspace.org/display/samvera/Samvera+Newspapers+Interest+Group) - The Samvera Newspapers Interest groups meets on the first Thursday of every month to discuss the Samvera newspapers project and general newspaper topics.
 * [Newspapers in Samvera IMLS Grant (formerly Hydra)](https://www.imls.gov/grants/awarded/lg-70-17-0043-17) - The official grant award for the project.
 * [National Digital Newspapers Program NDNP](https://www.loc.gov/ndnp/)

## Contact
  * Contact any contributors above by email, or ping us on [Samvera Community Slack channel(s)](http://slack.samvera.org/)

![Institute of Museum and Library Services Logo](https://imls.gov/sites/default/files/logo.png)

![University of Utah Logo](http://www.utah.edu/_images/imagine_u.png)

![Boston Public Library Logo](https://cor-liv-cdn-static.bibliocommons.com/images/MA-BOSTON-BRANCH/logo.png?1528788420451)

This software has been developed by and is brought to you by the Samvera community.  Learn more at the
[Samvera website](http://samvera.org/).

![Samvera Logo](https://wiki.duraspace.org/download/thumbnails/87459292/samvera-fall-font2-200w.png?version=1&modificationDate=1498550535816&api=v2)
