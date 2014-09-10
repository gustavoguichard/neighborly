# Neighbor.ly [![Build Status](https://secure.travis-ci.org/neighborly/neighborly.png?branch=master)](https://travis-ci.org/neighborly/neighborly) [![Coverage Status](https://coveralls.io/repos/neighborly/neighborly/badge.png?branch=master)](https://coveralls.io/r/neighborly/neighborly) [![Code Climate](https://codeclimate.com/github/neighborly/neighborly.png)](https://codeclimate.com/github/neighborly/neighborly) [![Dependency Status](https://gemnasium.com/neighborly/neighborly.png)](https://gemnasium.com/neighborly/neighborly) 

## Pivoting time :rocket: :rocket: :rocket:

The platform is moving to the bond market, selling municipal bonds.

From now on, you have two options:

* Join us on the [Bond MVP](https://github.com/neighborly/neighborly/milestones/Bond%20MVP) milestone and discover what are being planned and make them happen.
* Head to [neighborly/crowdfunding](https://github.com/neighborly/crowdfunding) for the crowdfunding platform. Related issues and pull request should be kept there.

## How to contribute

Please see the [CONTRIBUTING](CONTRIBUTING.md) file for information on contributing to Neighbor.ly's development.

### Style Guide

Make sure you follow our [style guide](https://github.com/neighborly/guides/).

## Quick Installation

To get everything working, you'll need to have these dependencies installed in your system:

* ImageMagick >= 6.3.5
* Qt ([to compile capybara webkit](https://github.com/thoughtbot/capybara-webkit/wiki/Installing-Qt-and-compiling-capybara-webkit))
* PostgreSQL >= 9.3 (with [postgresql-contrib](http://www.postgresql.org/docs/9.3/static/contrib.html))
* Redis >= 2.4
* Ruby 2.1.1

Then, you can run the following commands:

```bash
$ git clone https://github.com/neighborly/neighborly.git
$ cd neighborly
$ ./bin/bootstrap
$ foreman start
```

You are now running Neighborly on http://localhost:3000 with sample configuration. If you plan to use it more than just get it running, you should change configuration (check `db/seeds.rb` for examples) and maybe run development seeds:

```bash
$ rails runner db/development_seeds.rb
```

## Credits

Originally forked from [Catarse](https://github.com/catarse/catarse).
Adapted by [devton](https://github.com/devton), [josemarluedke](https://github.com/josemarluedke), [irio](https://github.com/irio), and [luminopolis](https://github.com/luminopolis). Made possible by support from hundreds of code contributors, financial support from Knight Foundation and Sunlight Foundation, plus lots of love & bbq sauce in downtown Kansas City, Missouri.

## License

Copyright (c) 2012 - 2014 Neighbor.ly. Licensed as free and open source under the [MIT License](MIT-LICENSE)
