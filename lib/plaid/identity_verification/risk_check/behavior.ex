defmodule Plaid.IdentityVerification.RiskCheck.Behavior do
  @moduledoc """
  [Summary of behavior attributes for risk check.](https://plaid.com/docs/api/products/identity-verification/#identity_verification-create-response-risk-check-behavior)
  """

  @behaviour Plaid.Castable

  @type t :: %__MODULE__{
          user_interactions: String.t(),
          fraud_ring_detected: String.t(),
          bot_detected: String.t()
        }

  defstruct [:user_interactions, :fraud_ring_detected, :bot_detected]

  @impl true
  def cast(generic_map) do
    %__MODULE__{
      user_interactions: generic_map["user_interactions"],
      fraud_ring_detected: generic_map["fraud_ring_detected"],
      bot_detected: generic_map["bot_detected"]
    }
  end
end
