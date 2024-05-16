defmodule MultiTranscriptionWeb.TranscriptionChannel do
  use MultiTranscriptionWeb, :channel

  def join("transcription:lobby", _params, socket) do
    {:ok, socket}
  end

  def handle_in("new_audio", %{"data" => base64_data}, socket) do
    binary_data = Base.decode64!(base64_data)
    path = write_to_temp_file(binary_data)

    MultiTranscription.Audio.speech_to_text(path, 20, fn ss, text ->
      IO.puts("Transcription at #{ss}: #{text}")
      broadcast!(socket, "new_transcription", %{"timestamp" => ss, "transcription" => text})
    end)

    {:noreply, socket}
  end

  defp write_to_temp_file(binary) do
    path = Path.join(System.tmp_dir(), "audio-#{:os.system_time(:millisecond)}.raw")
    File.write!(path, binary)
    path
  end
end
