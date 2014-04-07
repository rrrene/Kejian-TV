require 'test_helper'

class CoursewaresControllerTest < ActionController::TestCase
  setup do
    @courseware = coursewares(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:coursewares)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create courseware" do
    assert_difference('Courseware.count') do
      post :create, courseware: {  }
    end

    assert_redirected_to courseware_path(assigns(:courseware))
  end

  test "should show courseware" do
    get :show, id: @courseware
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @courseware
    assert_response :success
  end

  test "should update courseware" do
    patch :update, id: @courseware, courseware: {  }
    assert_redirected_to courseware_path(assigns(:courseware))
  end

  test "should destroy courseware" do
    assert_difference('Courseware.count', -1) do
      delete :destroy, id: @courseware
    end

    assert_redirected_to coursewares_path
  end
end
