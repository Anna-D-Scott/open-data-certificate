require 'test_helper'

class EmbedStatTest < ActiveSupport::TestCase

  test "should create an embed stat with a valid URL" do
    e = EmbedStat.create(referer: "http://example.com/page")

    assert e.valid?
    assert_equal EmbedStat.all.count, 1
  end

  test "should give an error if the URL is invalid" do
    e = EmbedStat.create(referer: "this is not a URL")

    refute e.valid?
    assert_equal e.errors.first, [:referer, "is not a valid URL"]
  end

  test "should generate a CSV" do
    5.times.each do |n|
      dataset = FactoryGirl.create(:dataset, title: "Dataset #{n}")
      2.times.each { |i| dataset.register_embed("http://example#{n}.com/#{i}") }
    end

    validator = Csvlint::Validator.new(StringIO.new(EmbedStat.csv))

    assert validator.valid?

    csv = CSV.parse(EmbedStat.csv)

    assert_equal csv.count, 11
    assert_equal csv.first, ["Dataset Name", "Dataset URL", "Referring URL", "First Detected"]

    assert_equal csv[1][0], "Dataset 0"
    assert_equal csv[1][1], "http://test.dev/datasets/1"
    assert_equal csv[1][2], "http://example0.com/0"
    assert_equal Date.parse(csv[1][3]), Date.today

    assert_equal csv.last[0], "Dataset 4"
    assert_equal csv.last[1], "http://test.dev/datasets/5"
    assert_equal csv.last[2], "http://example4.com/1"
    assert_equal Date.parse(csv.last[3]), Date.today
  end

end
