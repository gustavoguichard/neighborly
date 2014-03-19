# Neighbor.ly [![Build Status](https://secure.travis-ci.org/neighborly/neighborly.png?branch=master)](https://travis-ci.org/neighborly/neighborly) [![Coverage Status](https://coveralls.io/repos/neighborly/neighborly/badge.png?branch=master)](https://coveralls.io/r/neighborly/neighborly) [![Code Climate](https://codeclimate.com/github/neighborly/neighborly.png)](https://codeclimate.com/github/neighborly/neighborly) [![Dependency Status](https://gemnasium.com/neighborly/neighborly.png)](https://gemnasium.com/neighborly/neighborly) 

Welcome to the first open source fundraising toolkit for civic projects. Neighbor.ly began in February 2012 as a fork of the wildly successful Brazillian crowdfunding platform [Catarse](https://github.com/catarse/catarse). Working closely with the developers of that project, Neighbor.ly is building towards a full spectrum fundraising toolkit for civic projects.

## An open source fundraising toolkit for civic projects

This is the source code repository running [Neighbor.ly](http://neighbor.ly). We've decided to open source the code for our platform in the hopes that communities will find it useful as they embrace new funding sources for projects once covered by taxes and bonds.

Communities are always welcome and encouraged to list their projects on [Neighbor.ly](http://neighbor.ly). This codebase is intended for communities who would rather own and operate their own platforms. We also offer consultancy in setting the platform up as a "white label" extension to your exisitng website, and offer a variety of paid licensed versions built specifically for your needs (often easier and almost always cheaper than implementing this yourself). If you are interested in ways we can help you make the most of civic fundraising please [contact us](http://neighbor.ly).


# Getting started

### Internationalization

This software was originally created as [Catarse](https://github.com/catarse/catarse), Brazil's first crowdfunding platform.
It was first made in Portuguese then later English support added by [Daniel Walmsley](http://purpose.com). Neighbor.ly focused on making all aspects of the interface in US English. There are still some patches of both languages throughout the software, but overall there is good infrastructure in place to internationalize to the language of your choice.

### Translations

We hope to offer many languages in the future. So if you decide to implement Neighbor.ly in your own language, please let us know so we can include your language here.

### Payment gateways

Neighbor.ly supports payment gateways through payment engines. Payment engines are extensions to Neighbor.ly that implement a specific payment gateway logic.
The two current supported payment gateways are:
* Authorize.net for credit cards and e-checks
* PayPal

We're implementing [Balanced](http://balancedpayments.com/) on [balanced-payments](https://github.com/neighborly/neighborly/tree/balanced_payments) branch.

If you have created another payment engine, please contact us so we can link your engine here.

## How to contribute

Thank you for your interest in helping to advance this project. We are actively working on a public roadmap. Meanwhile, please feel free to [open issues](https://github.com/neighborly/neighborly/issues/new) with your concerns and [fix/implement](https://github.com/neighborly/neighborly/issues) something using pull requests. Probably the better way to do this is commenting on the issue so we can give you the responsibility of it. This will prevent more than one person to contribute with the same change.

### Coding style

* We prefer `{foo: 'bar'}` over `{:foo => 'bar'}`
* We prefer `->(foo){ bar(foo) }` over `lambda{|foo| bar(foo) }`

### Best practices (or how to get your pull request accepted faster)

We use RSpec, Capybara and Jasmine for the tests, and the best practices are:
* Create one acceptance test for each scenario of the feature you are trying to implement.
* Create model and controller tests to keep 100% of code coverage at least in the new parts that you are writing.
* Feel free to add specs to the code that is already in the repository without the proper coverage ;)
* Try to isolate models from controllers as best as you can.
* Regard the existing tests for a style guide, we try to use implicit spec subjects and lazy evaluation as often as we can.

## Quick Installation

**IMPORTANT**: Make sure you have postgresql-contrib ([Aditional Modules](http://www.postgresql.org/docs/9.3/static/contrib.html)) installed on your system.

```bash
$ git clone https://github.com/neighborly/neighborly.git
$ cd neighborly
$ cp config/database.sample.yml config/database.yml
$ vim config/database.yml
# change username/password and save
$ bundle install
$ rake db:create db:migrate db:seed
$ rails server
```

## Credits

Originally forked from [Catarse](https://github.com/catarse/catarse).
Adapted by [devton](https://github.com/devton), [josemarluedke](https://github.com/josemarluedke), and [luminopolis](https://github.com/luminopolis). Made possible by support from hundreds of code contributors, [financial support](http://www.knightfoundation.org/press-room/press-release/neighborly-expands-crowdfunding-service-civic-proj/) from the Knight Foundation, and lots of love & bbq sauce in downtown Kansas City, Missouri.

## License

Copyright (c) 2012 - 2014 Neighbor.ly. Licensed as free and open source under the [MIT License](MIT-LICENSE)
