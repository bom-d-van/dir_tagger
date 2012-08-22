require 'rubygems'
gem 'minitest'
require 'minitest/autorun'
require_relative 'path_document'

class TestPathCenter < MiniTest::Unit::TestCase
  include PathCenter
  def setup
    @doc = PathDocument.new('path/to/doc')
    @records = 3.times.map { |i| PathRecord.new(i, i.to_s) }
    last = @records.last
    @records << PathRecord.new(last.score + 10, last.path + '_different')
  end

  def stub_records &block
    @doc.stub :records, @records.clone, &block
  end

  def test_append
    stub_records do
      pr = @doc.append('new_path')
      assert_equal @records.push(pr), @doc.records
    end
  end

  def test_find_with_default_selector
    stub_records do
      pr = @records[0]
      assert_equal [pr], @doc.find(pr.path)
    end
  end

  def test_find_with_custome_selector
    stub_records do
      records = @records.clone
      records.pop
      found = @doc.find { |record| record.score != @records.last.score }
      assert_equal records, found, 'Should support CUSTOM SELECTOR'
    end
  end

  def test_top
    stub_records do
      pr = @records.last
      assert_equal pr, @doc.top(pr.path)
    end
  end

  def test_update
    stub_records do
      pr = @records.last.clone
      pr.score = 20
      assert_equal pr, @doc.update(pr.path, 20, 0)
    end
  end

  def test_remove
    stub_records do
      pr = @doc.remove '2'
      records = @records.clone
      records.delete(pr)
      # @doc.remove pr.path
      assert_equal records, @doc.records
    end
  end
end
