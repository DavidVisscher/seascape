defmodule SeascapeWeb.Effect do
  @doc """
  Similar to `Kernel.update_in/2`, but allows `handle_function` to return a (list of) effect(s).

  This function separates the struct from the path, which means that you can build it dynamically
  (using the functionality of the `Access` behaviour).

  iex> alias SeascapeWeb.Effect
  iex> struct = %{a: %{b: %{c: "Boom!"}}}
  iex> Effect.update_in(struct, [:a, :b, :c], &String.upcase/1)
  {%{a: %{b: %{c: "BOOM!"}}}, []}

  iex> Effect.update_in(struct, [:a, :b, :c], fn str -> {String.upcase(str), "Do a backflip"} end)
  {%{a: %{b: %{c: "BOOM!"}}}, ["Do a backflip"]}

  iex> Effect.update_in(struct, [:a, :c, :c], fn str -> {String.upcase(str), ["Do a backflip", 42]} end)
  {%{a: %{b: %{c: "BOOM!"}}}, ["Do a backflip", 42]}
  """
  defmacro update_in(path, handle_function) do
    quote do
      {inner, commands} =
        unquote(path)
        |> unquote(handle_function).()
        |> SeascapeWeb.Effect.normalize_result()

      result = put_in(unquote(path), inner)
      {result, commands}
    end
  end

  @doc """
  Similar to `Kernel.update_in/3`, but allows `handle_function` to return a (list of) effect(s).

  c.f. `SeascapeWeb.Effect.update_in/2`.
  This function separates the struct from the path, which means that you can build it dynamically
  (using the functionality of the `Access` behaviour).

  iex> alias SeascapeWeb.Effect
  iex> struct = %{a: %{b: %{c: "Boom!"}}}
  iex> Effect.update_in(struct, [:a, :b, :c], &String.upcase/1)
  {%{a: %{b: %{c: "BOOM!"}}}, []}

  iex> Effect.update_in(struct, [:a, :b, :c], fn str -> {String.upcase(str), "Do a backflip"} end)
  {%{a: %{b: %{c: "BOOM!"}}}, ["Do a backflip"]}

  iex> Effect.update_in(struct, [:a, :c, :c], fn str -> {String.upcase(str), ["Do a backflip", 42]} end)
  {%{a: %{b: %{c: "BOOM!"}}}, ["Do a backflip", 42]}
  """
  def update_in(struct, path, handle_function) do
    {inner, commands} =
      get_in(struct, path)
      |> handle_function.()
      |> normalize_result()

    result = put_in(struct, path, inner)
    {result, commands}
  end

  @doc """
  Normalized effectful state return values.

  - Turns `{state, command}` into `{state, [command]}`,
  - Turns `state` into `{state, []}`
  - Leaves `{state, [zero, or more, commands]}` alone.

  """
  def normalize_result({state, command}) when not(is_list(command)), do: {state, [command]}
  def normalize_result({state, commands}) when is_list(commands), do: {state, commands}
  def normalize_result(state), do: {state, []}
end
