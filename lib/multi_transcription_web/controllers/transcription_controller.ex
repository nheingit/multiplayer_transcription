defmodule MultiTranscriptionWeb.TranscriptionController do
  use MultiTranscriptionWeb, :controller

  def upload_audio(conn, %{"audio" => %Plug.Upload{path: path}}) do
    MultiTranscription.Audio.speech_to_text(path, 20, fn ss, text ->
      MultiTranscriptionWeb.Endpoint.broadcast("transcription:lobby", "new_transcription", %{
        "timestamp" => ss,
        "transcription" => text
      })
    end)

    send_resp(conn, :ok, "File uploaded successfully")
  end
end
