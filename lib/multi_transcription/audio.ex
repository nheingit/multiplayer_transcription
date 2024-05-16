defmodule MultiTranscription.Audio do
  # alternative
  # @repo "distil-whisper/distil-medium.en"
  def speech_to_text(path, chunk_time, func) do
    {:ok, stat} = MultiTranscription.MP3Stat.parse(path)
    duration = trunc(stat.duration)

    0..duration//chunk_time
    |> Task.async_stream(
      fn ss ->
        args = ~w(-ac 1 -ar 16k -f f32le -ss #{ss} -t #{chunk_time} -v quiet -)
        {data, 0} = System.cmd("ffmpeg", ["-i", path] ++ args)
        {ss, Nx.Serving.batched_run(WhisperServing, Nx.from_binary(data, :f32))}
      end,
      timeout: :infinity
    )
    |> Enum.map(fn
      {:ok, {ss, %{chunks: [%{text: text}]}}} -> func.(ss, text)
    end)
  end
end
