defmodule Plaid.IdentityVerification.RiskCheck.IdentityAbuseSignals.SyntheticIdentity do
  @moduledoc """
  [Data used in synthetic identity risk check.](https://plaid.com/docs/api/products/identity-verification/#identity_verification-create-response-risk-check-identity-abuse-signals-synthetic-identity)
  """

  @behaviour Plaid.Castable

  @type t :: %__MODULE__{
          score: integer()
        }

  defstruct [:score]

  @impl true
  def cast(generic_map) do
    %__MODULE__{score: generic_map["score"]}
  end
end