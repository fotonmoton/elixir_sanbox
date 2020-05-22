defmodule StudentTest do
  use ExUnit.Case

  test "creates a student" do
    {:ok, _} = GenServer.start_link(Student, "test_subject_1")
  end

  test "creates a student via Student.new" do
    {:ok, _} = Student.new("test_subject_2")
  end

  test "creates multiple distinct users" do
    {:ok, e_pid} = Student.new("test_subject_1")
    {:ok, g_pid} = Student.new("test_subject_2")
    assert e_pid != g_pid
  end
end
