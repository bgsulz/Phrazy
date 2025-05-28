const functions = require("firebase-functions");

const { onInit } = require("firebase-functions/v2/core");
const admin = require("firebase-admin");
const CryptoJS = require("crypto-js");

const DAILIES_COLLECTION = "dailies";
const PUZZLES_COLLECTION = "puzzles";

let db;

function hashLobbyName(lobbyName) {
  return CryptoJS.SHA256(lobbyName).toString();
}

function decodePlayerName(encodedName, lobbyName) {
  let key = lobbyName;
  let decoded = "";
  for (let i = 0; i < encodedName.length; i++) {
    decoded += String.fromCharCode(
      encodedName.charCodeAt(i) ^ key.charCodeAt(i % key.length)
    );
  }
  return decoded;
}

async function getPuzzleIdByDate(dateString) {
  if (!db) {
    throw new Error("Firestore DB not initialized.");
  }

  const dailyDocRef = db.collection(DAILIES_COLLECTION).doc(dateString);
  const dailyDocSnap = await dailyDocRef.get();

  if (!dailyDocSnap.exists) {
    throw new Error(`Daily document for date ${dateString} not found.`);
  }

  const dailyData = dailyDocSnap.data();
  if (!dailyData || !dailyData.hasOwnProperty("id")) {
    throw new Error(
      `Daily document for date ${dateString} is missing the 'id' field.`
    );
  }

  let puzzleId = dailyData.id;

  if (typeof puzzleId !== "number") {
    const parsedId = parseInt(puzzleId, 10);
    if (isNaN(parsedId)) {
      throw new Error(
        `Invalid puzzle ID format in daily document for ${dateString}.`
      );
    }
    puzzleId = parsedId;
  }

  return puzzleId;
}

async function fetchAndProcessScoreboard(lobbyName, puzzleId) {
  if (!db) {
    throw new Error("Firestore DB not initialized.");
  }
  const sanitizedLobbyName = lobbyName.trim().toLowerCase();
  const hashedLobbyName = hashLobbyName(sanitizedLobbyName);
  const docRef = db.doc(`lobbies/${hashedLobbyName}/scores/${puzzleId}`);
  const snapshot = await docRef.get();

  if (!snapshot.exists) {
    throw new Error(
      `No scoreboard found for lobby "${lobbyName}" and puzzle ID ${puzzleId}.`
    );
  }

  const data = snapshot.data();

  if (!data) {
    throw new Error(
      `Scoreboard data is empty for lobby "${lobbyName}" and puzzle ID ${puzzleId}.`
    );
  }

  const scoreboardData = {};
  for (const key in data) {
    const value = data[key];
    const decodedKey = decodePlayerName(key, lobbyName);
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
      scoreboardData[decodedKey] = parsedValue;
    }
  }
  return scoreboardData;
}

function sortScoreboardEntries(scoreboardData) {
  return Object.entries(scoreboardData).sort(([, a], [, b]) => a - b);
}

function formatScoreboardString(dateString, lobbyName, sortedEntries) {
  const year = dateString.substring(0, 4);
  const month = parseInt(dateString.substring(4, 6), 10);
  const day = parseInt(dateString.substring(6, 8), 10);
  const formattedDate = `${month}/${day}/${year}`;

  let formattedString = `Phrazy ${formattedDate} - Lobby ${lobbyName}\n`;

  for (const [name, time] of sortedEntries) {
    const minutes = Math.floor(time / 60000);
    const seconds = Math.floor((time % 60000) / 1000);

    const displayTime = `${minutes}:${seconds.toString().padStart(2, "0")}`;
    formattedString += `${name} - ${displayTime}\n`;
  }

  return formattedString;
}

function formatScoreboardJson(dateString, lobbyName, sortedEntries) {
  const year = dateString.substring(0, 4);
  const month = parseInt(dateString.substring(4, 6), 10);
  const day = parseInt(dateString.substring(6, 8), 10);
  const formattedDate = `${month}/${day}/${year}`;

  const scores = sortedEntries.map(([name, time]) => {
    return {
      name: name,
      time: time,
      displayTime: `${Math.floor(time / 60000)}:${Math.floor(
        (time % 60000) / 1000
      )
        .toString()
        .padStart(2, "0")}`,
    };
  });

  return {
    date: dateString,
    formattedDate: formattedDate,
    lobbyName: lobbyName,
    puzzleId: sortedEntries.length > 0 ? undefined : undefined,
    scores: scores,
  };
}

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

    try {
      const puzzleId = await getPuzzleIdByDate(dateString);
      const scoreboardData = await fetchAndProcessScoreboard(
        lobbyName,
        puzzleId
      );
      const sortedEntries = sortScoreboardEntries(scoreboardData);
      const formattedString = formatScoreboardString(
        dateString,
        lobbyName,
        sortedEntries
      );

      res.status(200).send(formattedString);
    } catch (error) {
      console.error(
        "Error in getFormattedLobbyScoreboardByDate:",
        error.message
      );
      res
        .status(
          error.message.includes("not found") || error.message.includes("empty")
            ? 404
            : 500
        )
        .send(error.message);
    }
  }
);

exports.getJsonLobbyScoreboardByDate = functions.https.onRequest(
  async (req, res) => {
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
      res
        .status(400)
        .json({ error: "Missing lobbyName or date query parameters." });
      return;
    }

    try {
      const puzzleId = await getPuzzleIdByDate(dateString);
      const scoreboardData = await fetchAndProcessScoreboard(
        lobbyName,
        puzzleId
      );
      const sortedEntries = sortScoreboardEntries(scoreboardData);

      const jsonResponse = formatScoreboardJson(
        dateString,
        lobbyName,
        sortedEntries
      );

      jsonResponse.puzzleId = puzzleId;

      res.status(200).json(jsonResponse);
    } catch (error) {
      console.error("Error in getJsonLobbyScoreboardByDate:", error.message);
      res
        .status(
          error.message.includes("not found") || error.message.includes("empty")
            ? 404
            : 500
        )
        .json({ error: error.message });
    }
  }
);
