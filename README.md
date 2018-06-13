<!-- TOC depthFrom:1 depthTo:6 withLinks:1 updateOnSave:1 orderedList:0 -->

- [Introduction](#introduction)
- [Overview](#overview)
	- [Purpose, Use, and Aims](#purpose-use-and-aims)
	- [Development Status](#development-status)
	- [Requirements](#requirements)
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

newspaper_works — Newspaper Works for Samvera   
===================================================
[![Build Status](https://travis-ci.org/marriott-library/newspaper_works.svg?branch=master)](https://travis-ci.org/marriott-library/newspaper_works)

# Introduction
The Newspapers in Samvera is an IMLS grant funded project to develop newspaper specific functionality for the [Samvera](http://samvera.org/) Hyrax framework.

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
------------
  * Ruby
  * Rails 5.x
  * [Bundler](http://bundler.io/)
  * [Hyrax](https://github.com/samvera/hyrax) 2.x
    - ..._and various Samvera dependencies that entails_.
  * A Hyrax-based Rails application.
    * `newspaper_works` is a gem/engine that can extend your application.

# Installation/Testing
Integrating newspaper_works in your application

Your Hyrax 2.x based application can extend and utilize `newspaper_works`

## Extending, Using
  * Add `gem 'newspaper_works'` to your Gemfile.
  * Run `bundle install`

## Basic Model Use (console)

_More here soon!_

## Application/Site Specific Configuration
  * In order to use some fields in forms, you will want to make sure you
    have a [username for Geonames](http://www.geonames.org/login),
    and configure that username in the `config.geonames_username`
    value in `config/intitializers/hyrax.rb` of your app.

    - This will help fields such as "Place of Publication" provide
      autocomplete using the Geonames service/vocabulary.

## Development and Testing Setup
* Clone `newspaper_works`:
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
    - `cd .internal_test_app; rails c test`
* For development, you may want to include a clone of `newspaper_works`
  in your app's Gemfile, either via `github:` or by `path:` in a local
  Gemfile used only for local development of your app.


# Credits
## Sponsoring Organizations

This gem is part of a project developed in a collaboration between
The University of Utah J. Willard Marriott Library and
Boston Public Library, as part of a "Newspapers in Samvera" project
grant funded by the [Institute for Museum and Library Services](https:///imls.gov).

The development team is grateful for input, collaboration, and support
we receive from the Samvera Community, related working groups,
and our project's advisory board.

## Contributors and Project Team

  * [Eben English (Boston Public Library)](https://github.com/ebenenglish)
  * [Brian McBride (University of Utah)](https://github.com/brianmcbride)
  * [Jacob Reed (University of Utah)](https://github.com/JacobR)
  * [Sean Upton (University of Utah)](https://github.com/seanupton)
  * Harish Maringhanti

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
