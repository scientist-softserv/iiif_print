IiifPrint
===================================================
Docs:
[![Apache 2.0 License](http://img.shields.io/badge/APACHE2-license-blue.svg)](./LICENSE)
[![Contribution Guidelines](http://img.shields.io/badge/CONTRIBUTING-Guidelines-blue.svg)](./CONTRIBUTING.md)

Jump in the Samvera Slack: <a href="http://slack.samvera.org/"><img src="https://status.slack.com/fonts/icons/icon_slack_hash_colored.svg" width="15" /></a>

<!-- TOC -->

- [Overview](#overview)
  - [Documentation](#documentation)
  - [Requirements](#requirements)
  - [Dependencies](#dependencies)
- [Installation](#installation)
  - [Changes made by the installer:](#changes-made-by-the-installer)
  - [Configuration to enable IiifPrint features](#configuration-to-enable-iiifprint-features)
    - [Model level configurations](#model-level-configurations)
    - [Application level configurations](#application-level-configurations)
- [Ingesting Content](#ingesting-content)
- [Developing, Testing, and Contributing](#developing-testing-and-contributing)
  - [Contributing](#contributing)
- [Acknowledgements](#acknowledgements)

<!-- /TOC -->

# Overview
IiifPrint is a gem (Rails "engine") for [Hyrax](https://hyrax.samvera.org/)-based digital repository applications to support displaying parent/child works in the same viewer (Universal Viewer) and the ability to search OCR from the parent work to the child work(s).

IiifPrint is not a stand-alone application. It is designed to be integrated into a new or existing Hyku (v4.0-v5.0) application.  Future development will include integrating it into a Hyrax-based application without Hyku and support for [IIIF Presentation Manifest version 3](https://iiif.io/api/presentation/3.0/) along with [AllinsonFlex](https://github.com/samvera-labs/allinson_flex) metadata profiles.

IiifPrint supports:
* OCR and ALTO creation
* full-text search
* OCR keyword match highlighting
* viewer with page navigation and deep zooming
* splitting of PDFs to LZW compressed TIFFs for viewing
* configuring how the manifest canvases are sorted in the viewer
* adding metadata fields to the manifest with faceted search links and external links
* excluding specified work types to be found in the catalog search

A complete list of features can be found [here](https://github.com/scientist-softserv/iiif_print/wiki/Features-List).

## Documentation
A set of helpful documents to help you learn more and deploy IiifPrint can be found on the [Project Wiki](https://github.com/scientist-softserv/iiif_print/wiki).

IiifPrint was developed against [Hyku](https://github.com/samvera/hyku) v4.0-v5.0. If your application uses [Bulkrax](https://github.com/samvera-labs/bulkrax), please ensure that its version is 5.0.1 or greater.

## Requirements

  * [Ruby](https://rubyonrails.org/) >=2.4
  * [Rails](https://rubyonrails.org/) ~>5.0
  * [Bundler](http://bundler.io/)
  * [Hyrax](https://github.com/samvera/hyrax) v2.5-v3.5.0
    - ..._and various [Samvera dependencies](https://github.com/samvera/hyrax#https://github.com/samvera/hyrax#how-to-run-the-code) that entails_.
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
  * [libgbm1](https://packages.debian.org/sid/libgbm1)

# Installation
IiifPrint easily integrates with your Hyrax 2.x applications.

* Add `gem 'iiif_print'` to your Gemfile.
* Run `bundle install`
* Run `rails generate iiif_print:install`
* Set config options as indicated below...


## Changes made by the installer:
* In `app/assets/javascripts/application.js`, it adds `//= require iiif_print`
* Adds `app/assets/stylesheets/iiif_print.scss`
* In `app/controllers/catalog_controller.rb`, it adds `include BlacklightIiifSearch::Controller`
* In `app/controllers/catalog_controller.rb`, it adds `add_index_field` and `iiif_search` config in the `configure_blacklight` block
* Adds `app/models/iiif_search_build.rb`
* In `config/routes.rb`, it adds `concern :iiif_search, BlacklightIiifSearch::Routes.new`
* In `config/routes.rb`, it adds `concerns :iiif_search` in the `resources :solr_documents` block
* Adds `config/initializers/iiif_print.rb`
* Adds three migrations, `CreateIiifPrintDerivativeAttachments`, `CreateIiifPrintIngestFileRelations`, and `CreateIiifPrintPendingRelationships`
* In `solr/conf/schema.xml`, it adds Blacklight IIIF Search autocomplete config
* In `solr/conf/solrconfig.xml`, it adds Blacklight IIIF Search autocomplete config
* Adds `solr/lib/solr-tokenizing_suggester-7.x.jar`

(It may be helpful to run `git diff` after installation to see all the changes made by the installer.)

## Configuration to enable IiifPrint features
**NOTE: WorkTypes and models are used synonymously here.**

### Model level configurations

In `app/models/{work_type}.rb` add `include IiifPrint.model_configuration` to any work types which require IiifPrint processing features (such as PDF splitting or OCR derivatives). See [lib/iiif_print.rb](./lib/iiif_print.rb) for details on configuration options.

```rb
# Example model Book which splits PDFs into child works of
# model Page, and runs only one derivative service (TIFFs)

class Book < ActiveFedora::Base
  include IiifPrint.model_configuration(
    pdf_split_child_model: Page,
    derivative_service_plugins: [
      IiifPrint::TIFFDerivativeService
    ]
  )
end
```

### Application level configurations

In `config/initializers/iiif_print.rb` specify application level configuration options.

```rb
IiifPrint.config do |config|
  # Add models to be excluded from search so the user would not see them in the search results.
  # By default, use the human readable versions like:
  config.excluded_model_name_solr_field_values = ['Generic Work', 'Image']

  # Add configurable solr field key for searching, default key is: 'human_readable_type_sim' if
  # another key is used, make sure to adjust the config.excluded_model_name_solr_field_values to match
  config.excluded_model_name_solr_field_key = 'some_solr_field_key'

  # Configure how the manifest sorts the canvases, by default it sorts by `:title`, but a different
  # model property may be desired such as :date_published
  config.sort_iiif_manifest_canvases_by = :date_published
end
```

TO ENABLE OCR Search (from the UV and catalog search)
### catalog_controller.rb
* In the CatalogController, find the add_search_field config block for 'all_fields'. Add advanced_parse: false, as seen in the following example:
```rb
    config.add_search_field('all_fields', label: 'All Fields', include_in_advanced_search: false, advanced_parse: false) do |field|
      all_names = config.show_fields.values.map(&:field).join(" ")
      title_name = 'title_tesim'
      field.solr_parameters = {
        qf: "#{all_names} file_format_tesim all_text_tsimv",
        pf: title_name.to_s
      }
    end
```
* Additionally, find and replace all instances of all_text_timv with all_text_tsimv, in the CatalogController.
* Set config.search_builder_class = IiifPrint::CatalogSearchBuilder

# Ingesting Content

IiifPrint supports a range of different ingest workflows:
* single-item ingest via the UI
* batch ingest of works from local files or remote files via Bulkrax

The ingest process is configurable at the model level, granting the option to:
* split a PDF into TIFFs and create child works
* create a full complement of derivatives, including TIFF, JP2, PDF, OCR text, and word-coordinate JSON

# Developing, Testing, and Contributing

We develop the IIIF Print gem using Docker and Docker Compose.  You'll want to clone this repository and run the following commands:

```shell
$ docker compose build
$ docker compose up
$ docker compose exec web bash
```

You'll now be inside the web container:

```shell
$ bundle exec rake
```

The above will build the test application (if it doesn't already exist).  During the rebuild you might get a notice on a conflict for files.  It will ask you to override.  We recommend that you select the "accept all" option (e.g. Typing <kbd>a</kbd>).

To rebuild the test application, delete the `.internal_test_app` directory.

## Contributing

If you're working on a PR for this project, create a feature branch off of `main`.

This repository follows the [Samvera Community Code of Conduct](https://samvera.atlassian.net/wiki/spaces/samvera/pages/405212316/Code+of+Conduct) and [language recommendations](https://github.com/samvera/maintenance/blob/master/templates/CONTRIBUTING.md#language).  Please ***do not*** create a branch called `master` for this repository or as part of your pull request; the branch will either need to be removed or renamed before it can be considered for inclusion in the code base and history of this repository.

We encourage anyone who is interested in newspapers and Samvera to contribute to this project. [How can I contribute?](https://github.com/samvera/hyrax/blob/master/.github/CONTRIBUTING.md)

# Acknowledgements

IIIF Print is a gem that was forked off [Newspaper Works](https://github.com/samvera-labs/newspaper_works), a powerful and versatile library for working with digitized newspapers. We would like to thank the team and maintainers of Newspaper Works for creating such a useful and well-designed gem. Our work on IIIF Print would not have been possible without their hard work and dedication.

In particular, we would like to express our gratitude to [brianmcbride](https://github.com/brianmcbride), [seanupton](https://github.com/seanupton), [ebenenglish](https://github.com/ebenenglish), and [JacobR](https://github.com/JacobR) for their pioneering efforts on Newspaper Works. Their foundation and expertise were invaluable in the development of this gem.

Thank you to the entire Newspaper Works team for creating and maintaining such a valuable resource for the Samvera community.
