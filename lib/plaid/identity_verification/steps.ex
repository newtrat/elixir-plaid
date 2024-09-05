defmodule Plaid.IdentityVerification.Steps do
  @moduledoc """
  [How far the user has gotten in each step of Identity Verification.](https://plaid.com/docs/api/products/identity-verification/#identity_verification-create-response-steps)
  """

  @behaviour Plaid.Castable

  @type t :: %__MODULE__{
          accept_tos: String.t(),
          verify_sms: String.t(),
          kyc_check: String.t(),
          documentary_verification: String.t(),
          selfie_check: String.t(),
          watchlist_screening: String.t(),
          risk_check: String.t()
        }

  defstruct [
    :accept_tos,
    :verify_sms,
    :kyc_check,
    :documentary_verification,
    :selfie_check,
    :watchlist_screening,
    :risk_check
  ]

  @impl true
  def cast(generic_map) do
    %__MODULE__{
      accept_tos: generic_map["accept_tos"],
      verify_sms: generic_map["verify_sms"],
      kyc_check: generic_map["kyc_check"],
      documentary_verification: generic_map["documentary_verification"],
      selfie_check: generic_map["selfie_check"],
      watchlist_screening: generic_map["watchlist_screening"],
      risk_check: generic_map["risk_check"]
    }
  end
end
