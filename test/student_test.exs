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

  test "Student.name gets the name of the student" do
    {:ok, pid} = Student.new("name")
    {:ok, "name"} = Student.name(pid)
  end

  test "Student.name does not crash on invalid student" do
    Student.name(nil)
  end

  test "Student.name returns an error with a reason for invalid student" do
    {:error, :notpid} = Student.name(nil)
    {:error, :notpid} = Student.name(0)
    {:error, :notpid} = Student.name("ok")
  end
end
