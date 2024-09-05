defmodule Plaid.IdentityVerification.KycCheck.Name do
  @moduledoc """
  [Summary of how name field matched during KYC check.](https://plaid.com/docs/api/products/identity-verification/#identity_verification-create-response-kyc-check-name)
  """

  @behaviour Plaid.Castable

  @type t :: %__MODULE__{
          summary: String.t()
        }

  defstruct [:summary]

  @impl true
  def cast(generic_map) do
    %__MODULE__{
      summary: generic_map["summary"]
    }
  end
end
