newspaper_works — Newspaper Works for Hyrax/Samvera
===================================================

Overview
--------

The Newspaper Works gem provides work type models and administrative
functionality for Hyrax-based Samvera applications in the space
of scanned newspaper media.  This gem can be included in a
Digital Asset Management application based on Hyrax 2.x.

### Purpose, Use, and Aims

This gem, while not a stand-alone application, can be integrated into an
application based on Hyrax 2.x easily to support a variety of cases for
management and ingest of primarily scanned (historic) newspaper archives.

### Status

This gem/engine is in early development, but

Requirements
------------

  * Ruby
  * Rails 5.x
  * [Bundler](http://bundler.io/)
  * [Hyrax](https://github.com/samvera/hyrax) 2.x
    - ..._and various Samvera dependencies that entails_.
  * A Hyrax-based Rails application.
    * `newspaper_works` is a gem/engine that can extend your application.


Integrating newspaper_works in Your Application
-----------------------------------------------

Your Hyrax 2.0 based application can extend and utilize `newspaper_works`

### Extending, Using

  * Add `gem 'newspaper_works'` to your Gemfile.
  * Run `bundle install`

### Basic Model Use (console)

_More here soon!_

### Application/Site Specific Configuration

  * In order to use some fields in forms, you will want to make sure you
    have a [username for Geonames](http://www.geonames.org/login),
    and configure that username in the `config.geonames_username`
    value in `config/intitializers/hyrax.rb` of your app.

    - This will help fields such as "Place of Publication" provide
      autocomplete using the Geonames service/vocabulary.


Development and Testing Setup
-----------------------------

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

Credits
-------

### Sponsoring Organizations

This gem is part of a project developed in a collaboration between
The University of Utah J. Willard Marriott Library and
Boston Public Library, as part of a "Newspapers in Samvera" project
grant funded by the Institute for Museum and Library Services (imls.gov).

The development team is grateful for input, collaboration, and support
we receive from the Samvera Community, related working groups,
and our project's advisory board.

### Contributors and Project Team

  * Eben English (BPL)
  * Brian McBride (University of Utah)
  * Jacob Reed (University of Utah)
  * Sean Upton (University of Utah)

### More Information / Contact

  * Contact any contributors above by email, or ping us on
    Samvera Community Slack channel(s).
