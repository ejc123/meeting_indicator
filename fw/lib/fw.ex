defmodule Fw do
  @moduledoc """
  Documentation for Fw.
  """
  alias Blinkchain.Color

  @colors %{:yellow => Color.parse("#FFFF00"),
           :green => Color.parse("#00FF00"),
           :red => Color.parse("#FF0000"),
           :blue => Color.parse("#6678EE"),
           :dark => Color.parse("#000000")
  }

  @brightness [2,4,6,8,10,12,14,16,18,20,22,24,26,28,30,32,30,28,26,24,22,20,18,16,14,12,10,8,6,4]

  def colors, do: @colors
  def brightness, do: @brightness

end
