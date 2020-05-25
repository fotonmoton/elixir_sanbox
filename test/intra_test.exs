defmodule IntraTest do
  use ExUnit.Case

  test "Intra creates without an error" do
    {:ok, pid} = Intra.new()
  end

  test "get students" do
    {:ok, pid} = Intra.new()
    students = Intra.students(pid)
    assert students == []
  end

  test "get projects" do
    {:ok, pid} = Intra.new()
    projects = Intra.projects(pid)
    assert projects == []
  end
end
