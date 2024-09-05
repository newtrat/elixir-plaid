defmodule Plaid.IdentityVerification.DocumentaryVerification.Document.Image do
  @moduledoc """
  [URLs for an image submitted for Plaid Identity Verification.](https://plaid.com/docs/api/products/identity-verification/#identity_verification-create-response-documentary-verification-documents-images)
  """

  @behaviour Plaid.Castable

  @type t :: %__MODULE__{
          original_front: String.t() | nil,
          original_back: String.t() | nil,
          cropped_front: String.t() | nil,
          cropped_back: String.t() | nil,
          face: String.t() | nil
        }

  defstruct [:original_front, :original_back, :cropped_front, :cropped_back, :face]

  @impl true
  def cast(generic_map) do
    %__MODULE__{
      original_front: generic_map["original_front"],
      original_back: generic_map["original_back"],
      cropped_front: generic_map["cropped_front"],
      cropped_back: generic_map["cropped_back"],
      face: generic_map["face"]
    }
  end
end
