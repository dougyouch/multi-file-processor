# frozen_string_literal: true

require 'rubygems'
require 'bundler'
require 'simplecov'
require 'pathname'
require 'fileutils'

SimpleCov.start

begin
  Bundler.require(:default, :development, :spec)
rescue Bundler::BundlerError => e
  warn e.message
  warn 'Run `bundle install` to install missing gems'
  exit e.status_code
end

BASE_DIR = Pathname.new(File.expand_path('..', __dir__))
$LOAD_PATH.unshift(BASE_DIR.join('lib'))
$LOAD_PATH.unshift(__dir__)
TMP_DIR = BASE_DIR.join('tmp')
require 'multi-file-processor'

require "rspec/expectations"

RSpec.configure do |config|
  config.before(:each) do
    FileUtils.rm_rf(TMP_DIR) if File.exist?(TMP_DIR)
    FileUtils.mkdir(TMP_DIR)
  end

  config.after(:all) do
    FileUtils.rm_rf(TMP_DIR) if File.exist?(TMP_DIR)
  end
end
