defmodule Plaid.IdentityVerification.KycCheck.Address do
  @moduledoc """
  [Summary of how address field matched during KYC check.](https://plaid.com/docs/api/products/identity-verification/#identity_verification-create-response-kyc-check-address)
  """

  @behaviour Plaid.Castable

  @type t :: %__MODULE__{
          summary: String.t(),
          po_box: String.t(),
          type: String.t()
        }

  defstruct [:summary, :po_box, :type]

  @impl true
  def cast(generic_map) do
    %__MODULE__{
      summary: generic_map["summary"],
      po_box: generic_map["po_box"],
      type: generic_map["type"]
    }
  end
end
