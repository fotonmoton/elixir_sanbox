defmodule ProjectTest do
  use ExUnit.Case

  test "creates a project" do
    %Project{name: "name"} = Project.new("name")
  end
end
