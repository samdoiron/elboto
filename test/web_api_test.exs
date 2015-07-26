defmodule APITest do
  use ExUnit.Case, async: true
  alias Elboto.WebAPI

  setup do
    HTTPoison.start()
  end

  test "uses the action given in the slack api url" do
    request = WebAPI.process_request(some_token, some_action)
    assert "https://slack.com/api/#{some_action}" == request[:url]
  end

  test "sends valid json as the post body" do
    request = WebAPI.process_request(some_token, some_action)
    Poison.decode(request[:body])
  end

  test "sends empty json object when no args provided" do
    body = request_with_empty_params[:body]
    assert body == "{}"
  end

  test "uses token in authorization header" do
    request = some_request
    assert request[:headers][:Authorization] == "Token #{some_token}"
  end

  test "uses given params in json post body" do
    body = some_request[:body] |> Poison.decode!
    assert body == some_args
  end

  test "correctly identifies error responses" do
    some_reason = "invalid_token"
    response = WebAPI.process_response(error_response(some_reason))
    assert response == {:error, some_reason}
  end

  def error_response(reason) do
    """
    { "ok": false,
      "error": "#{reason}"
    }
    """
  end

  def request_with_empty_params do
    WebAPI.process_request(some_token, some_action)
  end

  def some_non_error_response do
    """
    { "ok": true,
      "foo": "bar"
    }
    """
  end

  def some_request_with_params(params) do
    WebAPI.process_request(some_token, some_action, params)
  end

  def some_request do
    WebAPI.process_request(some_token, some_action, some_args)
  end

  def some_token do
    "some_token"
  end

  def some_action do
    "some.action"
  end

  def some_args do
    %{ 
      "foo" => "bar",
      "baz" => "quux"
    }
  end
end
