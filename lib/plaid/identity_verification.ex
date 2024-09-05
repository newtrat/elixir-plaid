defmodule Plaid.IdentityVerification do
  @moduledoc """
  [Plaid Identity Verification API](https://plaid.com/docs/api/products/identity-verification) calls and schema.
  """

  alias Plaid.Castable
  alias Plaid.IdentityVerification

  alias Plaid.IdentityVerification.{
    DocumentaryVerification,
    KycCheck,
    RiskCheck,
    SelfieCheck,
    Steps,
    Template,
    User
  }

  @behaviour Castable

  @type create_params :: %{
          client_user_id: String.t(),
          is_shareable: boolean(),
          template_id: String.t(),
          gave_consent: boolean(),
          user: %{
            optional(:email_address) => String.t(),
            optional(:phone_number) => String.t(),
            optional(:date_of_birth) => String.t(),
            optional(:name) => %{
              given_name: String.t(),
              family_name: String.t()
            },
            optional(:address) => %{
              :street => String.t(),
              optional(:street2) => String.t(),
              optional(:city) => String.t(),
              optional(:region) => String.t(),
              optional(:postal_code) => String.t(),
              country: String.t()
            },
            optional(:id_number) => %{
              value: String.t(),
              type: String.t()
            }
          },
          is_idempotent: boolean() | nil
        }

  @type list_params :: %{
          template_id: String.t(),
          client_user_id: String.t(),
          cursor: String.t() | nil
        }

  @type retry_params :: %{
          client_user_id: String.t(),
          template_id: String.t(),
          strategy: String.t(),
          user: User.t() | nil,
          steps:
            %{
              verify_sms: boolean(),
              kyc_check: boolean(),
              documentary_verification: boolean(),
              selfie_check: boolean()
            }
            | nil,
          is_shareable: boolean() | nil
        }

  @type t :: %__MODULE__{
          id: String.t(),
          client_user_id: String.t(),
          created_at: String.t(),
          completed_at: String.t() | nil,
          previous_attempt_id: String.t() | nil,
          shareable_url: String.t() | nil,
          template: Template.t(),
          user: User.t(),
          status: String.t(),
          steps: Steps.t(),
          documentary_verification: DocumentaryVerification.t() | nil,
          selfie_check: SelfieCheck.t() | nil,
          kyc_check: KycCheck.t() | nil,
          risk_check: RiskCheck.t() | nil,
          watchlist_screening_id: String.t() | nil,
          redacted_at: String.t() | nil,
          request_id: String.t()
        }

  defstruct [
    :id,
    :client_user_id,
    :created_at,
    :completed_at,
    :previous_attempt_id,
    :shareable_url,
    :template,
    :user,
    :status,
    :steps,
    :documentary_verification,
    :selfie_check,
    :kyc_check,
    :risk_check,
    :watchlist_screening_id,
    :redacted_at,
    :request_id
  ]

  @impl true
  def cast(generic_map) do
    %__MODULE__{
      id: generic_map["id"],
      client_user_id: generic_map["client_user_id"],
      created_at: generic_map["created_at"],
      completed_at: generic_map["completed_at"],
      previous_attempt_id: generic_map["previous_attempt_id"],
      shareable_url: generic_map["shareable_url"],
      template: Castable.cast(Template, generic_map["template"]),
      user: Castable.cast(User, generic_map["user"]),
      status: generic_map["status"],
      steps: Castable.cast(Steps, generic_map["steps"]),
      documentary_verification:
        Castable.cast(DocumentaryVerification, generic_map["documentary_verification"]),
      selfie_check: Castable.cast(SelfieCheck, generic_map["selfie_check"]),
      kyc_check: Castable.cast(KycCheck, generic_map["kyc_check"]),
      risk_check: Castable.cast(RiskCheck, generic_map["risk_check"]),
      watchlist_screening_id: generic_map["watchlist_screenng_id"],
      redacted_at: generic_map["redacted_at"],
      request_id: generic_map["request_id"]
    }
  end

  @doc """
  [Creates and returns a new Identity Verification for the user specified by `client_user_id`.](https://plaid.com/docs/api/products/identity-verification/#identity_verificationcreate)

  Makes a `POST /identity_verification/create` request.

  Params:
  * `client_user_id` - Your system's unique ID for this user.
  * `is_shareable` - Whether Plaid should expose a shareable URL.
  * `template_id` - Verification template to use.
  * `gave_consent` - Whether user has already accepted a privacy policy.
  * `user` - User information you've already collected, so Plaid doesn't re-collect
             the same information. Includes:
    * `email_address`
    * `phone_number` - in E.164 format.
    * `date_of_birth` - in YYYY-MM-DD format.
    * `name`
      * `given_name` - max 100 characters.
      * `family_name` - max 100 characters.
    * `address`
      * `street` - max 80 characters.
      * `street2` - max 50 characters.
      * `city` - max 100 characters.
      * `region` - ISO 3166-2.
      * `postal_code`
      * `country` - capitalized two-letter code, ISO 3166-1 alpha-2.
    * `id_number`
      * `value`
      * `type` - what `value` represents, e.g. "us_ssn_last_4".
  * `is_idempotent` - If an Identity Verification alreaady exists for this user,
                      this field tells Plaid whether to return that verification
                      (`is_idempotent`: true) or return a 400 Bad Request
                      (`is_idempotent`: false).

  ## Examples

      Plaid.IdentityVerification.create(
        %{
          client_user_id: "user-sandbox-b0e2c4ee-a763-4df5-bfe9-46a46bce993d",
          is_shareable: true,
          template_id: "idvtmp_52xR9LKo77r1Np",
          gave_consent: true,
          user: %{
            email_address: "acharleston@email.com",
            phone_number: "+11234567890",
            date_of_birth: "1975-01-18",
            name: %{
              given_name: "Anna",
              family_name: "Charleston"
            },
            address: %{
              street: "100 Market Street",
              street2: "Apt 1A",
              city: "San Francisco",
              region: "CA",
              postal_code: "94103",
              country: "US"
            },
            id_number: %{
              value: "123456789",
              type: "us_ssn"
            }
          }
        },
        client_id: "123",
        secret: "abc"
      )
      {:ok, %Plaid.IdentityVerification{}}

  """
  @spec create(create_params(), Plaid.config()) ::
          {:ok, IdentityVerification.t()} | {:error, Plaid.Error.t()}
  def create(payload, config) do
    Plaid.Client.call("/identity_verification/create", payload, IdentityVerification, config)
  end

  @doc """
  [Retrieves a previously created Identity Verification by its id.](https://plaid.com/docs/api/products/identity-verification/#identity_verificationget)

  Makes a `POST /identity_verification/get` request.

  Params:
  * `identity_verification_id` - id of an Identity Verification attempt.

  ## Examples:

      Plaid.IdentityVerification.get("idv_52xR9LKo77r1Np", client_id: "123", secret: "abc")
      {:ok, %Plaid.IdentityVerification{}}

  """

  @spec get(String.t(), Plaid.config()) ::
          {:ok, IdentityVerification.t()} | {:error, Plaid.Error.t()}
  def get(identity_verification_id, config) do
    Plaid.Client.call(
      "/identity_verification/get",
      %{identity_verification_id: identity_verification_id},
      IdentityVerification,
      config
    )
  end

  defmodule ListResponse do
    @moduledoc """
    [Plaid API /identity_verifications/list response schema.](https://plaid.com/docs/api/products/identity-verification/#identity_verificationlist)
    """
    @behaviour Castable

    @type t :: %__MODULE__{
            identity_verifications: [Plaid.IdentityVerification.t()],
            next_cursor: String.t() | nil,
            request_id: String.t()
          }

    defstruct [:identity_verifications, :next_cursor, :request_id]

    @impl true
    def cast(generic_map) do
      %__MODULE__{
        identity_verifications:
          Castable.cast_list(IdentityVerification, generic_map["identity_verifications"]),
        next_cursor: generic_map["next_cursor"],
        request_id: generic_map["request_id"]
      }
    end
  end

  @doc """
  [Returns a paginated list of Identity Verifications for a given user and template.](https://plaid.com/docs/api/products/identity-verification/#identity_verificationlist)

  Makes a `POST /identity_verification/list` request.

  Params:
  * `template_id` - Identity Verification template which you've set up on Plaid.
  * `client_user_id` - Your system's unique ID for this user.
  * `cursor` - Determines which page of results you'll receive. Each page
               returns a `next_cursor` you can use to get the next page.

  ## Examples:

      Plaid.IdentityVerification.list(
        %{
          template_id: "idvtmp_52xR9LKo77r1Np",
          client_user_id: "user-sandbox-b0e2c4ee-a763-4df5-bfe9-46a46bce993d",
        },
        client_id: "123",
        secret: "abc"
      )
      {:ok, Plaid.IdentityVerification.ListResponse{}}

  """
  @spec list(list_params(), Plaid.config()) :: {:ok, ListResponse.t()} | {:error, Plaid.Error.t()}
  def list(params, config) do
    Plaid.Client.call("/identity_verification/list", params, ListResponse, config)
  end

  @doc """
  [Allows a customer to retry their Identity Verification.](https://plaid.com/docs/api/products/identity-verification/#identity_verificationretry)

  Makes a `POST /identity_verification/retry` request.

  Params:
  * `client_user_id` - Your system's unique ID for this user.
  * `template_id` - Identity Verification template which you've set up on Plaid.
  * `strategy` - One of "reset", "incomplete", "infer", or "custom", indicating
                 which steps should be retried,
  * `user` - User information you've already collected, so Plaid doesn't re-collect
             the same information. Includes:
    * `email_address`
    * `phone_number` - in E.164 format.
    * `date_of_birth` - in YYYY-MM-DD format.
    * `name`
      * `given_name` - max 100 characters.
      * `family_name` - max 100 characters.
    * `address`
      * `street` - max 80 characters.
      * `street2` - max 50 characters.
      * `city` - max 100 characters.
      * `region` - ISO 3166-2.
      * `postal_code`
      * `country` - capitalized two-letter code, ISO 3166-1 alpha-2.
    * `id_number`
      * `value`
      * `type` - what `value` represents, e.g. "us_ssn_last_4".
  * `steps` - When `strategy` is "custom", specifies which steps to require.
              Includes boolean params:
    * `verify_sms`
    * `kyc_check`
    * `documentary_verification`
    * `selfie_check`
  * `is_shareable` - Whether Plaid should expose a shareable URL.

  ## Examples

      Plaid.IdentityVerification.retry(
        %{
          client_user_id: "user-sandbox-b0e2c4ee-a763-4df5-bfe9-46a46bce993d",
          template_id: "idvtmp_52xR9LKo77r1Np",
          strategy: "reset",
          user: %{
            email_address: "acharleston@email.com",
            phone_number: "+11234567890",
            date_of_birth: "1975-01-18",
            name: %{
              given_name: "Anna",
              family_name: "Charleston"
            },
            address: %{
              street: "100 Market Street",
              street2: "Apt 1A",
              city: "San Francisco",
              region: "CA",
              postal_code: "94103",
              country: "US"
            },
            id_number: %{
              value: "123456789",
              type: "us_ssn"
            }
          }
        },
        client_id: "123",
        secret: "abc"
      )
      {:ok, %Plaid.IdentityVerification{}}

  """
  @spec retry(retry_params(), Plaid.config()) ::
          {:ok, IdentityVerification.t()} | {:error, Plaid.Error.t()}
  def retry(params, config) do
    Plaid.Client.call("/identity_verification/retry", params, IdentityVerification, config)
  end
end
