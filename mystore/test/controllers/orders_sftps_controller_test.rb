require 'test_helper'

class OrdersSftpsControllerTest < ActionController::TestCase
  setup do
    @orders_sftp = orders_sftps(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:orders_sftps)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create orders_sftp" do
    assert_difference('OrdersSftp.count') do
      post :create, orders_sftp: { name: @orders_sftp.name }
    end

    assert_redirected_to orders_sftp_path(assigns(:orders_sftp))
  end

  test "should show orders_sftp" do
    get :show, id: @orders_sftp
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @orders_sftp
    assert_response :success
  end

  test "should update orders_sftp" do
    patch :update, id: @orders_sftp, orders_sftp: { name: @orders_sftp.name }
    assert_redirected_to orders_sftp_path(assigns(:orders_sftp))
  end

  test "should destroy orders_sftp" do
    assert_difference('OrdersSftp.count', -1) do
      delete :destroy, id: @orders_sftp
    end

    assert_redirected_to orders_sftps_path
  end
end
