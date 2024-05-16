defmodule MultiTranscriptionWeb.UserSocket do
  use Phoenix.Socket

  channel "transcription:lobby", MultiTranscriptionWeb.TranscriptionChannel

  def connect(_params, socket, _connect_info) do
    {:ok, socket}
  end

  def id(_socket), do: nil
end
