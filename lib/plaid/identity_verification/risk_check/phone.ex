defmodule Plaid.IdentityVerification.RiskCheck.Phone do
  @moduledoc """
  [Summary of phone attributes for risk check.](https://plaid.com/docs/api/products/identity-verification/#identity_verification-create-response-risk-check-phone)
  """

  @behaviour Plaid.Castable

  @type t :: %__MODULE__{
          linked_services: [String.t()]
        }

  defstruct [:linked_services]

  @impl true
  def cast(generic_map) do
    %__MODULE__{
      linked_services: generic_map["linked_services"]
    }
  end
end
