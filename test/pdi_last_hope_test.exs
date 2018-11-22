defmodule PdiLastHopeTest do
  use ExUnit.Case
  use Hound.Helpers

  hound_session()

  test "greets the world" do
    navigate_to("https://reservahora.extranjeria.gob.cl/inicio.action")
    #element = find_element(:name, "j_username")
    IO.inspect(page_title())
  end
end
