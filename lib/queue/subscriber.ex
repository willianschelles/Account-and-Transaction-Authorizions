defmodule Authorizer.Queue.Subscriber do
  use Agent

  def start_link(_opts) do
    if Mix.env() != :test do
      output_stream = File.stream!("output")

      _input_stream =
        "operations"
        |> File.stream!()
        |> process()
        |> Stream.into(output_stream)
        |> Stream.run()
    end

    Agent.start_link(fn -> %{} end)
  end

  defp process(events) do
    Stream.map(events, fn event ->
      event = Poison.decode!(event)
      output = Authorizer.run(event)
      write_output(output)
    end)
  end

  defp write_output(%Output{} = output) do
    Poison.encode!(
      %{
        account: %{
          active_card: output.account.active_card,
          available_limit: output.account.available_limit
        },
        violations: output.violations
      },
      pretty: true
    )
  end
end
