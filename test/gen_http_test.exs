defmodule GenHttpTest do
  use ExUnit.Case
  doctest GenHttp

  test "greets the world" do
    assert GenHttp.hello() == :world
  end
end
