defmodule Plaid.IdentityVerification.RiskCheck.IdentityAbuseSignals do
  @moduledoc """
  [Summary of risk check signals related to identity fraud.](https://plaid.com/docs/api/products/identity-verification/#identity_verification-create-response-risk-check-identity-abuse-signals)
  """

  alias Plaid.Castable

  alias Plaid.IdentityVerification.RiskCheck.IdentityAbuseSignals.{
    StolenIdentity,
    SyntheticIdentity
  }

  @behaviour Castable

  @type t :: %__MODULE__{
          synthetic_identity: SyntheticIdentity.t() | nil,
          stolen_identity: StolenIdentity.t() | nil
        }

  defstruct [:synthetic_identity, :stolen_identity]

  @impl true
  def cast(generic_map) do
    %__MODULE__{
      synthetic_identity: Castable.cast(SyntheticIdentity, generic_map["synthetic_identity"]),
      stolen_identity: Castable.cast(StolenIdentity, generic_map["stolen_identity"])
    }
  end
end
