require 'rubygems'
require 'multi_rails_init'

require 'test/unit'
require 'mocha'
require 'action_controller'

require File.dirname(__FILE__) + '/../lib/caches_page_via_http'

ActionController::Routing::Routes.draw do |map|
  map.connect ':controller/:action/:id'
end

class TestController < ActionController::Base
  caches_page :index
  def index
    render :text => 'ok'
  end
  def nocache
    render :text => 'ok'
  end
end

class CachesPageTest < Test::Unit::TestCase
  def setup
    @controller = TestController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new

    FileUtils.expects(:makedirs).never
    File.expects(:open).never
    File.expects(:delete).never
  end

  def test_not_crashing
    get 'index'
    assert_equal(200, @response.headers['Status'].to_i)
    assert_equal('ok', @response.body)
  end

  def test_cache_control_header
    get 'index'
    assert_equal('public; max-age=360', @response.headers['Cache-Control'])
  end

  def test_doesnt_affect_actions_not_cached
    get 'nocache'
    assert_equal(200, @response.headers['Status'].to_i)
    assert_equal('ok', @response.body)
    assert ['no-cache', 'private, max-age=0, must-revalidate'].include?(@response.headers['Cache-Control'])
  end
end