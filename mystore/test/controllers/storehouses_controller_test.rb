require 'test_helper'

class StorehousesControllerTest < ActionController::TestCase
  setup do
    @storehouse = storehouses(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:storehouses)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create storehouse" do
    assert_difference('Storehouse.count') do
      post :create, storehouse: { capacity: @storehouse.capacity, type: @storehouse.type }
    end

    assert_redirected_to storehouse_path(assigns(:storehouse))
  end

  test "should show storehouse" do
    get :show, id: @storehouse
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @storehouse
    assert_response :success
  end

  test "should update storehouse" do
    patch :update, id: @storehouse, storehouse: { capacity: @storehouse.capacity, type: @storehouse.type }
    assert_redirected_to storehouse_path(assigns(:storehouse))
  end

  test "should destroy storehouse" do
    assert_difference('Storehouse.count', -1) do
      delete :destroy, id: @storehouse
    end

    assert_redirected_to storehouses_path
  end
end
