defmodule MultiTranscription.Repo do
  use Ecto.Repo,
    otp_app: :multi_transcription,
    adapter: Ecto.Adapters.Postgres
end
