require 'test_helper'

class ProgressEntriesControllerTest < ActionController::TestCase
  setup do
    @progress_entry = progress_entries(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:progress_entries)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create progress_entry" do
    assert_difference('ProgressEntry.count') do
      post :create, progress_entry: { accuracy: @progress_entry.accuracy, opt,: @progress_entry.opt, }
    end

    assert_redirected_to progress_entry_path(assigns(:progress_entry))
  end

  test "should show progress_entry" do
    get :show, id: @progress_entry
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @progress_entry
    assert_response :success
  end

  test "should update progress_entry" do
    patch :update, id: @progress_entry, progress_entry: { accuracy: @progress_entry.accuracy, opt,: @progress_entry.opt, }
    assert_redirected_to progress_entry_path(assigns(:progress_entry))
  end

  test "should destroy progress_entry" do
    assert_difference('ProgressEntry.count', -1) do
      delete :destroy, id: @progress_entry
    end

    assert_redirected_to progress_entries_path
  end
end
