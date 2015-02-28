Contributing to the prometheus Cookbook
=========================================
The prometheus cookbook uses [Github][] to triage, manage,
and track issues and changes to the cookbook.

Everybody is welcome to submit patches, but we ask you keep the
following guidelines in mind:

- [Coding Standards](#coding-standards)
- [Testing](#testing)

Coding Standards
----------------
The submitted code should be compatible with the standard Ruby coding guidelines.
Here are some additional resources:

- [Ruby Style Guide](https://github.com/bbatsov/ruby-style-guide)
- [GitHub Styleguide](https://github.com/styleguide/ruby)

This cookbook is equipped with Rubocop, which will fail the build for violating
these standards.

Testing
-------
Whether your pull request is a bug fix or introduces new classes or methods to
the project, we kindly ask that you include tests for your changes. Even if it's
just a small improvement, a test is necessary to ensure the bug is never
re-introduced.

We understand that not all users are familiar with the testing ecosystem. This
cookbook is fully-tested using [Foodcritic](https://github.com/acrmp/foodcritic),
[Rubocop](https://github.com/bbatsov/rubocop),
and [Test Kitchen](https://github.com/test-kitchen/test-kitchen) with
[Serverspec](https://github.com/serverspec/serverspec) bussers.

Process
-------
1. Clone the git repository from GitHub:

        $ git clone git@github.com:rayrod2030/chef-prometheus.git

2. Make sure you have a sane [ChefDK][] development environment:

        $ chef version

3. Make any changes
4. Write tests to support those changes.
5. Run the tests:

        $ kitchen verify

6. Assuming the tests pass, commit your changes

[ChefDK]: https://downloads.chef.io/chef-dk/
[github]: https://github.com/rayrod2030/chef-prometheus/issues
