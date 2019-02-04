require 'test_helper'

class EnedisConnectionsControllerTest < ActionDispatch::IntegrationTest
  test "should get connect" do
    get enedis_connections_connect_url
    assert_response :success
  end

end
