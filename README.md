JSON Expressions
================

## Introduction

Your API is a contract between your service and your developers. It is important for you to know exactly what your JSON API is returning to the developers in order to make sure you don't accidentally change things without updating the documentations and/or bumping the API version number. Perhaps some controller tests for your JSON endpoints would help:

```ruby
# MiniTest::Unit example
class UsersControllerTest < MiniTest::Unit::TestCase
  def test_get_a_user
    server_response = get '/users/chancancode.json'

    json = JSON.parse server_response.body

    assert user = json['user']

    assert user_id = user['id']
    assert_equal 'chancancode', user['username']
    assert_equal 'Godfrey Chan', user['full_name']
    assert_equal 'godfrey@example.com', user['email']
    assert_equal 'Administrator', user['type']
    assert_kind_of Fixnum, user['points']
    assert_match /\Ahttps?\:\/\/.*\z/i, user['homepage']

    assert posts = user['posts']

    assert_kind_of Fixnum, posts[0]['id']
    assert_equal 'Hello world!', posts[0]['subject']
    assert_equal user_id, posts[0]['user_id']
    assert_include posts[0]['tags'], 'announcement'
    assert_include posts[0]['tags'], 'welcome'
    assert_include posts[0]['tags'], 'introduction'

    assert_kind_of Fixnum, posts[1]['id']
    assert_equal 'An awesome blog post', posts[1]['subject']
    assert_equal user_id, posts[1]['user_id']
    assert_include posts[0]['tags'], 'blog'
    assert_include posts[0]['tags'], 'life'
  end
end
```

There are many problems with this approach of JSON matching:

* It could get out of hand really quickly
* It is not very readable
* It flattens the structure of the JSON and it's difficult to visualize what the JSON actually looks like
* It does not guard against extra parameters that you might have accidentally included (password hashes, credit card numbers etc)
* Matching nested objects and arrays is tricky, especially when you don't want to enforce a particular ordering of the returned objects

json_expression allows you to express the structure and content of the JSON you're expecting with very readable Ruby code while preserving the flexibility of the "manual" approach.

## Dependencies

* Ruby 1.9+

## Usage

Add it to your Gemfile:

```ruby
gem 'json_expressions'
```

Add this to your test/spec helper file:
```ruby
# For MiniTest::Unit
require 'json_expressions/minitest'

# For RSpec
require 'json_expressions/rspec'
```

Which allows you to do...
```ruby
# MiniTest::Unit example
class UsersControllerTest < MiniTest::Unit::TestCase
  def test_get_a_user
    server_response = get '/users/chancancode.json'

    # This is what we expect the returned JSON to look like
    pattern = {
      user: {
        id:         :user_id,                    # "Capture" this value for later
        username:   'chancancode',               # Match this exact string
        full_name:  'Godfrey Chan',
        email:      'godfrey@example.com',
        type:       'Administrator',
        points:     Fixnum,                      # Any integer value
        homepage:   /\Ahttps?\:\/\/.*\z/i,       # Let's get serious
        created_at: WILDCARD_MATCHER,            # Don't care as long as it exists
        updated_at: WILDCARD_MATCHER,
        posts:      [
          {
            id:      Fixnum,
            subject: 'Hello world!',
            user_id: :user_id,                   # Match against the captured value
            tags:    [
              'announcement',
              'welcome',
              'introduction'
            ]                                    # Ordering of elements does not matter by default
          }.ignore_extra_keys!,                  # Skip the uninteresting stuff
          {
            id:      Fixnum,
            subject: 'An awesome blog post',
            user_id: :user_id,
            tags:    ['blog' , 'life']
          }.ignore_extra_keys!
        ].ordered!                               # Ensure the posts are in this exact order
      }
    }

    matcher = assert_json_match pattern, server_response.body # Returns the Matcher object

    # You can use the captured values for other purposes
    assert matcher.captures[:user_id] > 0
  end
end

# RSpec example
describe UsersController, "#show" do
  it "returns a user" do
    pattern = # See above...

    server_response = get '/users/chancancode.json'

    server_response.body.should match_json_expression(pattern)
  end
end
```

### `RSpec` Integration



### Basic Matching

This pattern
```ruby
{
  integer: 1,
  float:   1.1,
  string:  'Hello world!',
  boolean: true,
  array:   [1,2,3],
  object:  {key1: 'value1',key2: 'value2'},
  null:    nil,
}
```
matches the JSON object
```json
{
  "integer": 1,
  "float": 1.1,
  "string": "Hello world!",
  "boolean": true,
  "array": [1,2,3],
  "object": {"key1": "value1", "key2": "value2"},
  "null": null
}
```

### Wildcard Matching

You can use the WILDCARD_MATCHER to ignore keys that you don't care about (other than the fact that they exist).

This pattern
```ruby
[ WILDCARD_MATCHER, WILDCARD_MATCHER, WILDCARD_MATCHER, WILDCARD_MATCHER, WILDCARD_MATCHER, WILDCARD_MATCHER, WILDCARD_MATCHER ]
```
matches the JSON array
```json
[ 1, 1.1, "Hello world!", true, [1,2,3], {"key1": "value1","key2": "value2"}, null]
```

Furthermore, because the pattern is just plain old Ruby code, you can also write:
```ruby
[ WILDCARD_MATCHER ] * 7
```

### Object Equality

By default, json_expressions uses `Object#===` to match against the corresponding value in the target JSON. In most cases, this method behaves exactly the same as `Object#==`. However, certain classes override this method to provide specialized behavior (notably `Regexp` and `Module`, see below). If you find this undesirable for certain classes, you can explicitly opt them out and json_expressions will call `Object#==` instead:

```ruby
# This is the default setting
JsonExpressions::Matcher.skip_triple_equal_on = [ ]

# To add more modules/classes
# JsonExpressions::Matcher.skip_triple_equal_on << MyClass

# To turn this off completely
# JsonExpressions::Matcher.skip_triple_equal_on = [ BasicObject ]
```

### Regular Expressions

Since `Regexp` overrides `Object#===` to mean "matches", you can use them in your patterns and json_expressions will do the right thing:
```ruby
{ hex: /\A0x[0-9a-f]+\z/i }
```
matches
```json
{ "hex": "0xC0FFEE" }
```
but not
```json
{ "hex": "Hello world!" }
```

### Type Matching

`Module` (and by inheritance, `Class`) overrides `===` to mean `instance of`. You can exploit this behavior to do type matching:
```ruby
{
  integer: Fixnum,
  float:   Float,
  string:  String,
  boolean: Boolean,
  array:   Array,
  object:  Hash,
  null:    NilClass,
}
```
matches the JSON object
```json
{
  "integer": 1,
  "float": 1.1,
  "string": "Hello world!",
  "boolean": true,
  "array": [1,2,3],
  "object": {"key1": "value1", "key2": "value2"},
  "null": null
}
```

### Capturing

Similar to how "captures" work in Regexp, you can capture the value of certain keys for later use:
```ruby
matcher = JsonExpressions::Matcher.new({
  key1: :key1,
  key2: :key2,
  key3: :key3
})

matcher =~ JSON.parse('{"key1":"value1", "key2":"value2", "key3":"value3"}') # => true

matcher.captures[:key1] # => "value1"
matcher.captures[:key2] # => "value2"
matcher.captures[:key3] # => "value3"
```

If the same symbol is used multiple times, json_expression will make sure they agree. This pattern
```ruby
{
  key1: :capture_me,
  key2: :capture_me,
  key3: :capture_me
}
```
matches
```json
{
  "key1": "Hello world!",
  "key2": "Hello world!",
  "key3": "Hello world!"
}
```
but not
```json
{
  "key1": "value1",
  "key2": "value2",
  "key3": "value3"
}
```

### Ordering

By default, all arrays and JSON objects (i.e. Ruby hashes) are assumed to be unordered. This means
```ruby
[ 1, 2, 3, 4, 5 ]
```
will match
```json
[ 5, 3, 2, 1, 4 ]
```
and
```ruby
{ key1: 'value1', key2: 'value2' }
```
will match
```json
{ "key2": "value2", "key1": "value1" }
```

You can change this behavior in a case-by-case manner:
```ruby
{
  "unordered_array" => [1,2,3,4,5].unordered!, # calling unordered! is optional as it's the default
  "ordered_array"   => [1,2,3,4,5].ordered!,
  "unordered_hash"  => {'a'=>1, 'b'=>2}.unordered!,
  "ordered_hash"    => {'a'=>1, 'b'=>2}.ordered!
}
```

Or you can change the defaults:
```ruby
# Default for these are true
JsonExpressions::Matcher.assume_unordered_arrays = false
JsonExpressions::Matcher.assume_unordered_hashes = false
```

### "Strictness"

By default, all arrays and JSON objects (i.e. Ruby hashes) are assumed to be "strict". This means any extra elements or keys in the JSON target will cause the match to fail:
```ruby
[ 1, 2, 3, 4, 5 ]
```
will not match
```json
[ 1, 2, 3, 4, 5, 6 ]
```
and
```ruby
{ key1: 'value1', key2: 'value2' }
```
will not match
```json
{ "key1": "value1", "key2": "value2", "key3": "value3" }
```

You can change this behavior in a case-by-case manner:
```ruby
{
  strict_array:    [1,2,3,4,5].strict!, # calling strict! is optional as it's the default
  forgiving_array: [1,2,3,4,5].forgiving!,
  strict_hash:     {'a'=>1, 'b'=>2}.strict!,
  forgiving_hash:  {'a'=>1, 'b'=>2}.forgiving!
}
```

They also come with some more sensible aliases:
```ruby
{
  strict_array:    [1,2,3,4,5].reject_extra_values!,
  forgiving_array: [1,2,3,4,5].ignore_extra_values!,
  strict_hash:     {'a'=>1, 'b'=>2}.reject_extra_keys!,
  forgiving_hash:  {'a'=>1, 'b'=>2}.ignore_extra_keys!
}
```

Or you can change the defaults:
```ruby
# Default for these are true
JsonExpressions::Matcher.assume_strict_arrays = false
JsonExpressions::Matcher.assume_strict_hashes = false
```

## Support for `MiniTest::Spec` (and other testing frameworks)

The `Matcher` class itself is written in a testing-framework-agnostic manner. This allows you to easily write custom helpers/matchers for your favorite testing framework. `MiniTest::Spec` is on my TODO list, but it is not a high priority for me personally, as I currently don't use it. If you need this now, write it yourself and submit a pull request - it's really easy, I promise (see `lib/json_expressions/minitest/unit/helpers.rb` for inspiration).

## Contributing

Please use the [GitHub issue tracker](https://github.com/chancancode/json_expressions/issues) for bugs and feature requests. If you could submit a pull request - that's even better!

## License

This library is distributed under the MIT license. Please see the LICENSE file.