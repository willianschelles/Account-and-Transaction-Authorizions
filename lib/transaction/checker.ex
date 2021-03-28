defmodule Authorizer.Transaction.Checker do
  alias Authorizer.Transaction

  @spec verify(Transaction.t(), list()) :: list()
  def verify(%Transaction{} = transaction, violations) do
    []
  end
end
