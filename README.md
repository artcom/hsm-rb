# Hierarchical Statemachine for Ruby

Reference is http://en.wikipedia.org/wiki/UML_state_machine

## Developer Setup

### Install dependencies and setup environment

Requires the specified ruby version to be installed. For details see `.ruby-version.dev`

Enter directory and first link up the `.ruby*` files:

    $ ln -s .ruby-version.dev .ruby-version
    $ ln -s .ruby-gemset.dev .ruby-gemset
    $ cd . # to activate this setting

Alternatively the rake-task `rvm:dotfiles:link` can be used

    $ rake rvm:dotfiles:link
    $ cd .

Then install all required gems via

    $ bundle

### Running tests

* Without coverage

  `$ bundle exec guard`

* With coverage

  `$ COVERAGE=html bundle exec guard`

## License
Please consult the `License` file.

# TODO 

Please see issue tracker.

* Add visualization
* Make state machine inspection simpler
* Revisit syntax (DSL ?), structure
