import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");
let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken },
});
liveSocket.connect();

let socket = new Socket("/socket", { params: { token: window.userToken } });
socket.connect();

let channel = socket.channel("transcription:lobby", {});

channel
  .join()
  .receive("ok", (resp) => {
    console.log("Joined successfully", resp);
  })
  .receive("error", (resp) => {
    console.log("Unable to join", resp);
  });

let mediaRecorder;
let audioChunks = [];

let Transcription = {
  mounted() {
    this.handleEvent("new_transcription", ({ transcription }) => {
      let list = document.getElementById("transcriptions");
      let listItem = document.createElement("li");
      listItem.innerHTML = `<strong>${new Date().toLocaleTimeString()}:</strong> ${transcription}`;
      list.appendChild(listItem);
    });

    document.getElementById("start_recording").addEventListener("click", () => {
      navigator.mediaDevices.getUserMedia({ audio: true }).then((stream) => {
        mediaRecorder = new MediaRecorder(stream);
        mediaRecorder.start();

        mediaRecorder.addEventListener("dataavailable", (event) => {
          audioChunks.push(event.data);
        });

        mediaRecorder.addEventListener("stop", () => {
          let audioBlob = new Blob(audioChunks, { type: "audio/wav" });
          audioBlob.arrayBuffer().then((buffer) => {
            let binaryString = new Uint8Array(buffer);
            let base64String = btoa(
              String.fromCharCode.apply(null, binaryString),
            );
            channel.push("new_audio", { data: base64String });
          });

          audioChunks = [];
        });
      });
    });

    document.getElementById("stop_recording").addEventListener("click", () => {
      mediaRecorder.stop();
    });
  },
};

let Hooks = {
  Transcription,
};

export { Hooks };

// import { Socket } from "phoenix";
// import { LiveSocket } from "phoenix_live_view";
//
// let csrfToken = document
//   .querySelector("meta[name='csrf-token']")
//   .getAttribute("content");
// let liveSocket = new LiveSocket("/live", Socket, {
//   params: { _csrf_token: csrfToken },
// });
//
// let socket = new Socket("/socket");
// socket.connect();
//
// let channel = socket.channel("transcription:lobby", {});
// channel
//   .join()
//   .receive("ok", (resp) => {
//     console.log("Joined successfully", resp);
//   })
//   .receive("error", (resp) => {
//     console.log("Unable to join", resp);
//   });
//
// let mediaRecorder;
// let audioChunks = [];
// let Transcription = {
//   mounted() {
//     this.handleEvent("new_transcription", ({ transcription }) => {
//       let list = document.getElementById("transcriptions");
//       let listItem = document.createElement("li");
//       listItem.innerHTML = `<strong>${new Date().toLocaleTimeString()}:</strong> ${transcription}`;
//       list.appendChild(listItem);
//     });
//
//     document.getElementById("start_recording").addEventListener("click", () => {
//       navigator.mediaDevices.getUserMedia({ audio: true }).then((stream) => {
//         mediaRecorder = new MediaRecorder(stream);
//         mediaRecorder.start();
//
//         mediaRecorder.addEventListener("dataavailable", (event) => {
//           audioChunks.push(event.data);
//         });
//
//         mediaRecorder.addEventListener("stop", () => {
//           let audioBlob = new Blob(audioChunks, { type: 'audio/wav' });
//             audioBlob.arrayBuffer().then(buffer => {
//               let binaryString = new Uint8Array(buffer);
//               let base64String = btoa(String.fromCharCode.apply(null, binaryString));
//               channel.push("new_audio", { data: base64String });
//             });
//
//           audioChunks = [];
//         });
//       });
//     });
//
//     document.getElementById("stop_recording").addEventListener("click", () => {
//       mediaRecorder.stop();
//     });
//   },
// };
//
// let Hooks = {
//   Transcription,
// };
// export { Hooks };
