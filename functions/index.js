const functions = require("firebase-functions");

const { onInit } = require("firebase-functions/v2/core");
const admin = require("firebase-admin");

const DAILIES_COLLECTION = "dailies";
const PUZZLES_COLLECTION = "puzzles";

let db;

onInit(async () => {
  console.log("Initializing Firebase Admin SDK and Firestore...");

  if (!admin.apps.length) {
    admin.initializeApp();
  }

  db = admin.firestore();
  console.log("Firebase Admin SDK and Firestore initialized.");
});

exports.getFormattedLobbyScoreboardByDate = functions.https.onRequest(
  async (req, res) => {
    if (!db) {
      console.error("Firestore DB not initialized!");
      res
        .status(500)
        .send("Server not ready: Firestore initialization failed.");
      return;
    }

    res.set("Access-Control-Allow-Origin", "*");
    if (req.method === "OPTIONS") {
      res.set("Access-Control-Allow-Methods", "GET, POST");
      res.set("Access-Control-Allow-Headers", "Content-Type");
      res.status(204).send("");
      return;
    }

    const lobbyName = req.query.lobbyName;
    const dateString = req.query.date;

    if (!lobbyName || !dateString) {
      res.status(400).send("Missing lobbyName or date query parameters.");
      return;
    }

    let puzzleId = null;
    try {
      const dailyDocRef = db.collection(DAILIES_COLLECTION).doc(dateString);
      const dailyDocSnap = await dailyDocRef.get();

      if (!dailyDocSnap.exists) {
        res
          .status(404)
          .send(`Daily document for date ${dateString} not found.`);
        return;
      }

      const dailyData = dailyDocSnap.data();
      if (!dailyData || !dailyData.hasOwnProperty("id")) {
        res
          .status(404)
          .send(
            `Daily document for date ${dateString} is missing the 'id' field.`
          );
        return;
      }

      puzzleId = dailyData.id;

      if (typeof puzzleId !== "number") {
        const parsedId = parseInt(puzzleId, 10);
        if (isNaN(parsedId)) {
          res
            .status(500)
            .send(
              `Invalid puzzle ID format in daily document for ${dateString}.`
            );
          return;
        }
        puzzleId = parsedId;
      }
    } catch (error) {
      console.error("Error fetching puzzle ID for date:", error);
      res.status(500).send("Error retrieving puzzle ID from date.");
      return;
    }

    try {
      const docRef = db.doc(`lobbies/${lobbyName}/scores/${puzzleId}`);
      const snapshot = await docRef.get();

      if (!snapshot.exists) {
        res
          .status(404)
          .send(
            `No scoreboard found for lobby "${lobbyName}" and puzzle ID ${puzzleId} (from date ${dateString}).`
          );
        return;
      }

      const data = snapshot.data();

      if (!data) {
        res
          .status(404)
          .send(
            `Scoreboard data is empty for lobby "${lobbyName}" and puzzle ID ${puzzleId}.`
          );
        return;
      }

      const scoreboardData = {};
      for (const key in data) {
        const value = data[key];
        let parsedValue = null;
        if (typeof value === "number") {
          parsedValue = value;
        } else if (typeof value === "string") {
          parsedValue = parseInt(value, 10);
          if (isNaN(parsedValue)) {
            parsedValue = null;
          }
        }

        if (parsedValue !== null) {
          scoreboardData[key] = parsedValue;
        }
      }

      const sortedEntries = Object.entries(scoreboardData).sort(
        ([, a], [, b]) => a - b
      );

      let formattedString = "";
      formattedString += `Phrazy ${dateString} - Lobby ${lobbyName}\n`;

      for (const [name, time] of sortedEntries) {
        const minutes = Math.floor(time / 60000);
        const seconds = Math.floor((time % 60000) / 1000);
        const milliseconds = time % 1000;

        const displayTime = `${minutes}:${seconds
          .toString()
          .padStart(2, "0")}`;//.${milliseconds.toString().padStart(3, "0")}`;
        formattedString += `${name} - ${displayTime}\n`;
      }

      res.status(200).send(formattedString);
    } catch (error) {
      console.error("Error fetching or formatting scoreboard:", error);
      res.status(500).send("Error retrieving scoreboard data.");
    }
  }
);
