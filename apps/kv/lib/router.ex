defmodule KV.Router do
  @doc """
  Dispatch the given `mod`, `fun`, `args` requests
  to the appropriate node based on the `bucket`.
  """
  def route(bucket, mod, fun, args) do
    first = :binary.first(bucket)

    entry =
      Enum.find(table(), fn {enum, _node} ->
        first in enum
      end) || no_entry_error(bucket)

    nod = elem(entry, 1)

    if nod == node() do
      apply(mod, fun, args)
    else
      {KV.RouterTasks, nod}
      |> Task.Supervisor.async(KV.Router, :route, [bucket, mod, fun, args])
      |> Task.await
    end
  end

  defp no_entry_error(bucket) do
    raise "could not find entry for #{inspect bucket} in table #{inspect table()}"
  end

  @doc """
  The routing table
  """
  def table do
    [
      {?a..?m, :"foo@me-desktop"},
      {?n..?z, :"bar@me-desktop"}
    ]
  end
end
