defmodule Elboto.API do
  @module_doc ~S"""
  A thin wrapper for the Slack API based on the 
  """

  @base_url "https://slack.com/api/"

  def get(token, action, opts \\ []) do
    HTTPotion.get(@base_url <> action).body
    |> Poison.decode
    |> check_for_errors
  end

  defp check_for_errors(response) do
    case response do
      %{:ok => true} -> {:ok, response}
      %{:ok => false} -> {:error, Dict.get(response, 'error')}
    end
  end
end

