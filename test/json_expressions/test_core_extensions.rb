require 'minitest_helper'
require 'json_expressions/core_extensions'

module JsonExpressions
  class TestCoreExtensions < ::MiniTest::Unit::TestCase
    METHODS_MODULE_MAPPING = {
      :ordered   => Ordered,
      :unordered => Unordered,
      :strict    => Strict,
      :forgiving => Forgiving
    }.freeze

    def setup
      @hash = {'a'=>1, 'b'=>2, 'c'=>3}
      @array = [1, 2, 3]
    end

    METHODS_MODULE_MAPPING.each do |meth, mod|
      ['array', 'hash'].each do |klass|
        eval <<-EOM, nil, __FILE__, __LINE__ + 1
          def test_#{klass}_#{meth}
            refute @#{klass}.is_a? #{mod}
            #{klass} = @#{klass}.#{meth}
            refute_equal #{klass}.object_id, @#{klass}.object_id
            assert #{klass}.is_a? #{mod}
          end

          def test_#{klass}_#{meth}!
            refute @#{klass}.is_a? #{mod}
            @#{klass}.#{meth}!
            assert @#{klass}.is_a? #{mod}
          end

          def test_#{klass}_#{meth}?
            refute @#{klass}.#{meth}?
            @#{klass}.extend #{mod}
            assert @#{klass}.#{meth}?
          end
        EOM
      end
    end

    def test_hash_reject_extra_keys
      refute @hash.strict?
      assert @hash.reject_extra_keys.strict?
      refute @hash.strict?
    end

    def test_hash_reject_extra_keys!
      refute @hash.strict?
      @hash.reject_extra_keys!
      assert @hash.strict?
    end

    def test_hash_ignore_extra_keys
      refute @hash.forgiving?
      assert @hash.ignore_extra_keys.forgiving?
      refute @hash.forgiving?
    end

    def test_hash_ignore_extra_keys!
      refute @hash.forgiving?
      @hash.ignore_extra_keys!
      assert @hash.forgiving?
    end

    def test_array_reject_extra_values
      refute @array.strict?
      assert @array.reject_extra_values.strict?
      refute @array.strict?
    end

    def test_array_reject_extra_values!
      refute @array.strict?
      @array.reject_extra_values!
      assert @array.strict?
    end

    def test_array_ignore_extra_values
      refute @array.forgiving?
      assert @array.ignore_extra_values.forgiving?
      refute @array.forgiving?
    end

    def test_array_ignore_extra_values!
      refute @array.forgiving?
      @array.ignore_extra_values!
      assert @array.forgiving?
    end

    def test_cannot_mark_an_unordered_object_as_ordered
      @hash.unordered!
      assert_raises RuntimeError do
        @hash.ordered!
      end
    end

    def test_cannot_mark_an_ordered_object_as_unordered
      @hash.ordered!
      assert_raises RuntimeError do
        @hash.unordered!
      end
    end

    def test_cannot_mark_a_forgiving_object_as_strict
      @hash.forgiving!
      assert_raises RuntimeError do
        @hash.strict!
      end
    end

    def test_cannot_mark_a_strict_object_as_forgiving
      @hash.strict!
      assert_raises RuntimeError do
        @hash.forgiving!
      end
    end
  end
end