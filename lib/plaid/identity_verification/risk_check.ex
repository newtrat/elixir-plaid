defmodule Plaid.IdentityVerification.RiskCheck do
  @moduledoc """
  [Additional information for risk_check step of Identity Verification.](https://plaid.com/docs/api/products/identity-verification/#identity_verification-create-response-risk-check)
  """

  alias Plaid.Castable

  alias Plaid.IdentityVerification.RiskCheck.{
    Behavior,
    Device,
    Email,
    IdentityAbuseSignals,
    Phone
  }

  @behaviour Castable

  @type t :: %__MODULE__{
          status: String.t(),
          behavior: Behavior.t() | nil,
          email: Email.t() | nil,
          phone: Phone.t() | nil,
          devices: [Device.t()],
          identity_abuse_signals: IdentityAbuseSignals.t() | nil
        }

  defstruct [:status, :behavior, :email, :phone, :devices, :identity_abuse_signals]

  @impl true
  def cast(generic_map) do
    %__MODULE__{
      status: generic_map["status"],
      behavior: Castable.cast(Behavior, generic_map["behavior"]),
      email: Castable.cast(Email, generic_map["email"]),
      phone: Castable.cast(Phone, generic_map["phone"]),
      devices: Castable.cast_list(Device, generic_map["devices"]),
      identity_abuse_signals:
        Castable.cast(IdentityAbuseSignals, generic_map["identity_abuse_signals"])
    }
  end
end
