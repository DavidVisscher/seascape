defmodule SeascapeWeb.EffectInterpreter do
  require Logger

  def execute_effects(socket, commands) do
    Enum.reduce(commands, socket, &execute_effect/2)
  end

  def execute_effect(command, socket) do
    case command do
      command when is_function(command, 0) ->
        command.()
        socket
      command when is_function(command, 1) ->
        command.(socket)
      _other ->
        Logger.debug("Unknown command #{inspect(command)}, socket: #{inspect(socket)}")
        socket
    end
  end
end
