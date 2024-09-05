defmodule Plaid.IdentityVerification.RiskCheck.Device do
  @moduledoc """
  [Summary of device attributes for risk check.](https://plaid.com/docs/api/products/identity-verification/#identity_verification-create-response-risk-check-devices)
  """

  @behaviour Plaid.Castable

  @type t :: %__MODULE__{
          ip_proxy_type: String.t() | nil,
          ip_spam_list_count: integer() | nil,
          ip_timezone_offset: String.t() | nil
        }

  defstruct [:ip_proxy_type, :ip_spam_list_count, :ip_timezone_offset]

  @impl true
  def cast(generic_map) do
    %__MODULE__{
      ip_proxy_type: generic_map["ip_proxy_type"],
      ip_spam_list_count: generic_map["ip_spam_list_count"],
      ip_timezone_offset: generic_map["ip_timezone_offset"]
    }
  end
end
