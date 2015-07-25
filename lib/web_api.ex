defmodule Elboto.WebAPI do
  @module_doc ~S"""
  A thin wrapper for the Slack API.

  `perform_action` is the only method that should be used externally, but
  `process_request` and `process_response` are both public so that they
  can be tested in isolation from the actual slack api.
  """

  @base_url "https://slack.com/api/"

  def perform_action(token, action, params \\ %{}) do
    process_request(token, action, params)
    |> perform_request
    |> process_response
  end

  def process_request(token, action, params \\ %{}) do
    [
      url: get_api_url(action),
      body: encode_request_body(params),
      headers: get_request_headers(token)
    ]
  end

  def process_response(response) do
    response
    |> decode_response_body
    |> check_for_errors
  end

  defp perform_request(request) do
    HTTPoison.post(request[:url], [
        body: request[:body],
        headers: request[:headers]
    ]).body
  end

  defp get_api_url(action), do: @base_url <> action

  defp get_request_headers(token) do
    [
      Authorization: "Token #{token}"
    ]
  end

  defp check_for_errors(response) do
    case response do
      %{"ok" => true} -> {:ok, response}
      %{"ok" => false} -> {:error, Dict.get(response, "error")}
    end
  end

  defp encode_request_body(body), do: Poison.encode!(body)

  defp decode_response_body(body), do: Poison.decode!(body)
end

