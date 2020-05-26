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
    not_student = spawn(fn -> nil end)
    {:error, :not_student} = Student.name(nil)
    {:error, :not_student} = Student.name(0)
    {:error, :not_student} = Student.name("ok")
    {:error, :not_student} = Student.name(not_student)
  end

  test "Student.projects gets the projects of the student" do
    {:ok, pid} = Student.new("name")
    {:ok, []} = Student.projects(pid)
  end

  test "Student.projects does not crash on invalid student" do
    Student.projects(nil)
  end

  test "Student.projects returns an error with a reason for invalid student" do
    not_student = spawn(fn -> nil end)
    {:error, :not_student} = Student.projects(nil)
    {:error, :not_student} = Student.projects(0)
    {:error, :not_student} = Student.projects("ok")
    {:error, :not_student} = Student.projects(not_student)
  end

  test "student can subscribe to a project" do
    project = %Project{name: "fdf"}
    {:ok, student} = Student.new("name")
    :ok = Student.subscribe(student, project)
  end

  test "student has the subscribed project in their projects list" do
    project = %Project{name: "fdf"}
    {:ok, student} = Student.new("name")
    :ok = Student.subscribe(student, project)
    {:ok, projects} = Student.projects(student)
    assert Enum.member?(projects, project)
  end

  test "student subscription adds only one project to the project list" do
    project = %Project{name: "fdf"}
    {:ok, student} = Student.new("name")
    :ok = Student.subscribe(student, project)
    {:ok, projects} = Student.projects(student)
    assert length(projects) == 1
  end

  test "student can unsubscribe from a project" do
    project = %Project{name: "fdf"}
    {:ok, student} = Student.new("name")
    :ok = Student.subscribe(student, project)
    :ok = Student.unsubscribe(student, project)
    {:ok, projects} = Student.projects(student)
    refute length(projects) == 1
  end

  test "student can't unsubscribe from a project it's not subscribed to" do
    project = %Project{name: "fdf"}
    project2 = %Project{name: "fractol"}
    {:ok, student} = Student.new("name")
    {:error, :not_subscribed} = Student.unsubscribe(student, project)
    :ok = Student.subscribe(student, project2)
    {:error, :not_subscribed} = Student.unsubscribe(student, project)
  end

  test "subscription to student events" do
    # I think student process can store all subscribed pids and
    # broadcast major events to subscribed processes
    {:ok, student} = Student.new("name")

    # maybe function name should be different
    :ok = Student.Event.subscribe(student, self())
  end

  test "project subscription event" do
    {:ok, student} = Student.new("name")
    :ok = Student.Event.subscribe(student, self())
    Student.subscribe(student, Project.new("project"))
    assert_receive {:subscribed_to_project, _student, _project}
  end
end
