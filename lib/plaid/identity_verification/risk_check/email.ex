defmodule Plaid.IdentityVerification.RiskCheck.Email do
  @moduledoc """
  [Summary of email attributes for risk check.](https://plaid.com/docs/api/products/identity-verification/#identity_verification-create-response-risk-check-email)
  """

  @behaviour Plaid.Castable

  @type t :: %__MODULE__{
          is_deliverable: String.t(),
          breach_count: integer() | nil,
          first_breached_at: String.t() | nil,
          last_breached_at: String.t() | nil,
          domain_registered_at: String.t() | nil,
          domain_is_free_provider: String.t(),
          domain_is_custom: String.t(),
          domain_is_disposable: String.t(),
          top_level_domain_is_suspicious: String.t(),
          linked_services: [String.t()]
        }

  defstruct [
    :is_deliverable,
    :breach_count,
    :first_breached_at,
    :last_breached_at,
    :domain_registered_at,
    :domain_is_free_provider,
    :domain_is_custom,
    :domain_is_disposable,
    :top_level_domain_is_suspicious,
    :linked_services
  ]

  @impl true
  def cast(generic_map) do
    %__MODULE__{
      is_deliverable: generic_map["is_deliverable"],
      breach_count: generic_map["breach_count"],
      first_breached_at: generic_map["first_breached_at"],
      last_breached_at: generic_map["last_breached_at"],
      domain_registered_at: generic_map["domain_registered_at"],
      domain_is_free_provider: generic_map["domain_is_free_provider"],
      domain_is_custom: generic_map["domain_is_custom"],
      domain_is_disposable: generic_map["domain_is_disposable"],
      top_level_domain_is_suspicious: generic_map["top_level_domain_is_suspicious"],
      linked_services: generic_map["linked_services"]
    }
  end
end
