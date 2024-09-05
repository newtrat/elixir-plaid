defmodule Plaid.IdentityVerification.SelfieCheck.Selfie.Capture do
  @moduledoc """
  [Image or video URL of a submitted selfie.](https://plaid.com/docs/api/products/identity-verification/#identity_verification-create-response-selfie-check-selfies-capture)
  """

  @behaviour Plaid.Castable

  @type t :: %__MODULE__{
          image_url: String.t() | nil,
          video_url: String.t() | nil
        }

  defstruct [:image_url, :video_url]

  @impl true
  def cast(generic_map) do
    %__MODULE__{
      image_url: generic_map["image_url"],
      video_url: generic_map["video_url"]
    }
  end
end
