### v0.8.2 [view commit logs](https://github.com/chancancode/json_expressions/compare/0.8.1...0.8.2)

* Bugfix: require 'rspec/core' instead of 'rspec' (#12 by @pda)
* Improved matcher output when using RSpec (#11 by @milkcocoa)
* Various documentation improvements
* Various Rakefile improvements. The gem now builds correctly on Travis

### v0.8.1 [view commit logs](https://github.com/chancancode/json_expressions/compare/0.8.0...0.8.1)

* Fat finger: reverted a change in 0.8.0 which changed the default value of `assume_unordered_arrays` from true to false. Added tests to make sure this never happens again.

### v0.8.0 [view commit logs](https://github.com/chancancode/json_expressions/compare/0.7.2...0.8.0)

* Added Test::Unit support.
* Added MiniTest::Spec support.
* BREAKING: Changed internal structure of MiniTest support code. This shouldn't affect you unless you have been manually requiring and including the MiniTest helpers yourself.
* Use of `WILDCARD_MATCHER` (the constant) inside a `MiniTest::Unit::TestCase` is now discouraged. Instead, you are encouraged to use `wildcard_matcher` (the method) instead. README has been updated.
* Removed WILDCARD_MATCHER#match and the corresponding test. Since support for Object#match has been removed in v0.7.0, this should no longer be necessary.

### v0.7.2 [view commit logs](https://github.com/chancancode/json_expressions/compare/0.7.1...0.7.2)

* Bugfix: Corrected a misbehaving require statement in minitest helpers (Fixes #2)

### v0.7.1 [view commit logs](https://github.com/chancancode/json_expressions/compare/0.7.0...0.7.1)

* Bugfix: Correctly matching `false` inside a symbol-keyed hash (Fixes #1)

### v0.7.0 [view commit logs](https://github.com/chancancode/json_expressions/compare/0.6.0...0.7.0)

* BREAKING: Removed support for Object#match in favor of Object#===
* BREAKING: Removed configuration option JsonExpressions::Matcher.skip_match_on

### v0.6.0 [view commit logs](https://github.com/chancancode/json_expressions/compare/0.5.0...0.6.0)

* Added non-bang version of `strict`, `forgiving`, `ordered` and `unordered`
* Added RSpec support (thanks @bobthecow for the [initial implementation](https://gist.github.com/3086558))
* Added support for `Symobl` hash keys
* Switched examples in README to use `Symbol` hash keys
* Improved error messages

### v0.5.0

* Initial release