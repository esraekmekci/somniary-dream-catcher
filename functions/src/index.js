const { onRequest } = require('firebase-functions/v2/https');
const { defineSecret } = require('firebase-functions/params');
const logger = require('firebase-functions/logger');
const admin = require('firebase-admin');
const cors = require('cors');
const fs = require('fs');
const os = require('os');
const path = require('path');

admin.initializeApp();
const db = admin.firestore();
const storage = admin.storage();

const corsHandler = cors({ origin: true });
const MISTRAL_API_KEY = defineSecret('MISTRAL_API_KEY');

function languageName(code) {
  if ((code || '').startsWith('tr')) return 'Turkish';
  if ((code || '').startsWith('en')) return 'English';
  return 'the same language as the user';
}

function safetyLineFor(code) {
  if ((code || '').startsWith('tr')) {
    return 'Bu yorum eğlence ve kişisel farkındalık amaçlıdır.';
  }
  if ((code || '').startsWith('en')) {
    return 'This interpretation is for reflection and entertainment.';
  }
  return 'Add a short safety line in the same language.';
}

function buildSystemPrompt(languageCode) {
  return `You are Somnia, a playful, emotionally intelligent dream interpreter. Your goal is to give users a warm, natural, friend-like dream reading that still feels thoughtful and safe. Sound close, lively, and human. Do not sound clinical, robotic, or like a template.

Core rules:
Do not use markdown syntax, headings, labels, section titles, bullets, numbering, asterisks, or emojis.
Do not expose internal structure words such as "symbols", "questions", "themes", "analysis", or "follow-up questions" to the user as visible headings.
Write as smooth natural prose with short paragraphs only.
Do not claim certainty, prophecy, or guaranteed future outcomes.
Do not provide medical, legal, or financial advice.
Avoid fear-based statements, threats, or absolute warnings.
Prefer soft language like "this can point to", "it may reflect", "it feels connected to", "one possible reading is".
Keep the user feeling safe, seen, and never judged.
If the user expresses self-harm intent or severe distress, respond with empathy and encourage seeking professional help and trusted people, and suggest contacting local emergency services if in immediate danger.

Personalization rules:
You must actively use the user's profile and previous dreams when available. Do not ignore them.
If age, gender, relationship status, stress level, sleep level, work situation, zodiac sign, or recurring dream patterns are available, weave them naturally into the interpretation.
If a profile field is missing, do not invent it.
Make the reading feel personal: connect the dream to the user's current life phase, emotional load, relationship dynamics, and repeated dream motifs.
Add gentle life insight and soft near-future possibilities, but keep them non-deterministic.
Offer practical, emotionally useful suggestions tailored to the user's profile.

Content rules:
Open with a warm 1-sentence reaction that feels like a close, intuitive friend.
Then give a clear overall interpretation in 3-5 sentences.
Then naturally weave in 2-4 of the dream's most important symbols and their traditional meanings inside the prose instead of listing them as a labeled section.
Then add a personalized reflection that connects the dream to the user's profile and prior dreams. Mention recurring emotional patterns if relevant.
Include light guidance or suggestions about what the user can pay attention to in life, relationships, stress, rest, or decisions.
Do not ask direct questions.
Instead of asking questions, close with 1-2 invitation-style premium nudges such as offering a deeper love-life reading, stress-based reading, or a clearer interpretation if the user shares another detail. These should sound natural and enticing, not salesy or pushy.

Output shape:
Keep the response to 3 or 4 short paragraphs.
The last line should be a short invitation sentence, not a question mark.
Respond entirely in ${languageName(languageCode)}.
Also add this safety line exactly (or translated if needed): "${safetyLineFor(languageCode)}"`;
}

const SYMBOL_HINTS = [
  'yılan',
  'su',
  'uçmak',
  'düşmek',
  'diş',
  'ölüm',
  'bebek',
  'ev',
  'merdiven',
  'kapı',
  'ayna',
];

const FALLBACK_SYMBOLS = [
  { tr: 'yılan', en: 'snake', keys: ['yılan', 'snake', 'serpent'] },
  { tr: 'su', en: 'water', keys: ['su', 'water', 'ocean', 'sea', 'river'] },
  { tr: 'uçmak', en: 'flying', keys: ['uç', 'uçmak', 'flying', 'float', 'soar'] },
  { tr: 'düşmek', en: 'falling', keys: ['düş', 'falling', 'fell', 'drop'] },
  { tr: 'diş', en: 'teeth', keys: ['diş', 'teeth', 'tooth'] },
  { tr: 'ölüm', en: 'death', keys: ['ölüm', 'death', 'dead'] },
  { tr: 'bebek', en: 'baby', keys: ['bebek', 'baby', 'infant'] },
  { tr: 'ev', en: 'house', keys: ['ev', 'house', 'home'] },
  { tr: 'merdiven', en: 'stairs', keys: ['merdiven', 'stairs', 'stairway'] },
  { tr: 'kapı', en: 'door', keys: ['kapı', 'door', 'gate'] },
  { tr: 'ayna', en: 'mirror', keys: ['ayna', 'mirror'] },
  { tr: 'araba', en: 'car', keys: ['araba', 'car', 'vehicle'] },
  { tr: 'alyans', en: 'ring', keys: ['alyans', 'ring', 'engagement'] },
];

function todayYmd() {
  const now = new Date();
  const y = now.getUTCFullYear();
  const m = String(now.getUTCMonth() + 1).padStart(2, '0');
  const d = String(now.getUTCDate()).padStart(2, '0');
  return `${y}-${m}-${d}`;
}

function wrapCors(req, res, handler) {
  return corsHandler(req, res, async () => {
    if (req.method === 'OPTIONS') {
      res.status(204).send('');
      return;
    }
    if (req.method !== 'POST') {
      res.status(405).json({ error: 'Only POST is allowed.' });
      return;
    }

    try {
      await handler();
    } catch (error) {
      logger.error(error);
      const message = error instanceof Error ? error.message : 'Unknown error';
      res.status(500).json({ error: message });
    }
  });
}

function getMistralKey() {
  const key = MISTRAL_API_KEY.value();
  if (!key) {
    throw new Error('MISTRAL_API_KEY is not configured.');
  }
  return key;
}

function mistralModel(isPremium) {
  if (isPremium) {
    return process.env.MISTRAL_MODEL_PREMIUM || 'mistral-small-latest';
  }
  return process.env.MISTRAL_MODEL_FREE || 'mistral-small-latest';
}

function readMistralContent(content) {
  if (typeof content === 'string') return content.trim();
  if (Array.isArray(content)) {
    return content
      .map((part) => {
        if (typeof part === 'string') return part;
        if (part && typeof part === 'object' && typeof part.text === 'string') return part.text;
        return '';
      })
      .join('\n')
      .trim();
  }
  return '';
}

async function callMistralText({ model, instruction, text }) {
  const apiKey = getMistralKey();
  const url = 'https://api.mistral.ai/v1/chat/completions';

  const response = await fetch(url, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      Authorization: `Bearer ${apiKey}`,
    },
    body: JSON.stringify({
      model,
      temperature: 0.7,
      messages: [
        { role: 'system', content: instruction },
        { role: 'user', content: text },
      ],
    }),
  });

  if (!response.ok) {
    const raw = await response.text();
    throw new Error(`Mistral request failed (${response.status}): ${raw}`);
  }

  const json = await response.json();
  return readMistralContent(json?.choices?.[0]?.message?.content);
}

async function callMistralAudioTranscription({ model, mimeType, audioBase64 }) {
  const apiKey = getMistralKey();
  const url = 'https://api.mistral.ai/v1/audio/transcriptions';
  const audioBytes = Buffer.from(audioBase64, 'base64');
  const form = new FormData();
  form.append('model', model);
  form.append('file', new Blob([audioBytes], { type: mimeType }), 'dream-audio.m4a');
  form.append(
    'prompt',
    'Transcribe this audio to plain text in the same spoken language. Do not translate.',
  );

  const response = await fetch(url, {
    method: 'POST',
    headers: {
      Authorization: `Bearer ${apiKey}`,
    },
    body: form,
  });

  if (!response.ok) {
    const raw = await response.text();
    throw new Error(`Mistral transcription failed (${response.status}): ${raw}`);
  }

  const json = await response.json();
  return String(json?.text || '').trim();
}

function buildDeveloperPrompt({ profile, themesSummary, recentDreams, newDreamText }) {
  return `Context:
User profile: ${JSON.stringify(profile || {})}
Prior dream themes summary: ${themesSummary || ''}
Recent dreams (last 3-5):
${recentDreams.length ? recentDreams.map((d, i) => `- ${i + 1}. ${d}`).join('\n') : '- (none)'}
Symbol dictionary reference (non-deterministic): ${SYMBOL_HINTS.join(', ')}
Task:
Interpret the new dream described by the user.
You must use the profile and prior dreams as real context, not as background noise.
First do a traditional-symbolic layer, then add a personalized psychological reflection based on the profile and prior themes.
If birthDate exists, infer approximate age/life stage from it and use that carefully.
If gender, relationship, stressLevel, sleepLevel, occupation, or zodiacSign exist, tailor the reading to them naturally.
If recent dreams or themes show repetition, explicitly mention the recurring pattern and what it may suggest emotionally.
Do not output visible labels like "Symbols" or "Questions".
Do not ask follow-up questions.
End with natural invitation-style lines that hint a deeper reading is possible if the user shares extra detail or unlocks a more detailed interpretation.
Keep it gentle, vivid, friend-like, and non-deterministic.

User message:
${newDreamText}`;
}

function normalizeLanguageCode(raw) {
  const v = String(raw || '').trim().toLowerCase();
  if (!v) return 'tr';
  if (v.startsWith('en')) return 'en';
  if (v.startsWith('tr')) return 'tr';
  // Keep other ISO-like codes if model returns them.
  if (/^[a-z]{2}(-[a-z]{2})?$/.test(v)) return v;
  return 'tr';
}

function heuristicLanguageCode(text) {
  const s = String(text || '').toLowerCase();
  if (/[ğüşöçıİ]/i.test(s)) return 'tr';
  const trWords = [' ve ', ' bir ', ' için ', ' gibi ', ' ama ', ' rüya ', ' bugün '];
  const enWords = [' the ', ' and ', ' i ', ' my ', ' dream ', ' was ', ' with '];
  const trScore = trWords.reduce((a, w) => a + (s.includes(w) ? 1 : 0), 0);
  const enScore = enWords.reduce((a, w) => a + (s.includes(w) ? 1 : 0), 0);
  if (enScore > trScore) return 'en';
  return 'tr';
}

async function detectLanguageCode(text, isPremium) {
  try {
    const raw = await callMistralText({
      model: mistralModel(isPremium),
      instruction:
        'Detect language of the user text. Return ONLY JSON: {"language":"<iso-639-1>"}',
      text,
    });
    const parsed = parseJsonObject(raw);
    return normalizeLanguageCode(parsed.language);
  } catch (e) {
    logger.warn('detectLanguageCode fallback', e);
    return heuristicLanguageCode(text);
  }
}

function parseJsonObject(raw) {
  const trimmed = (raw || '').trim();
  if (!trimmed) return {};

  try {
    return JSON.parse(trimmed);
  } catch (_) {
    const match = trimmed.match(/\{[\s\S]*\}/);
    try {
      return JSON.parse(match[0]);
    } catch {
      return {};
    }
  }
}


function derivePrimaryMood(themes) {
  const t = (themes || []).join(' ').toLowerCase();
  if (/kayg|anx|fear|panic|korku/.test(t)) return 'Anxious';
  if (/calm|peace|huzur|sakin/.test(t)) return 'Calm';
  if (/joy|neşe|umut|happy/.test(t)) return 'Peaceful';
  return 'Curious';
}

function fallbackAutoTitle(dreamText, symbols, themes, languageCode) {
  const map = (languageCode || '').startsWith('en')
    ? {
      'su': 'Deep Waters',
      'water': 'Deep Waters',
      'uçmak': 'Rising Flight',
      'flying': 'Rising Flight',
      'kapı': 'At The Door',
      'door': 'At The Door',
      'ev': 'Silent House',
      'house': 'Silent House',
      'ayna': 'Mirror Room',
      'mirror': 'Mirror Room',
      'merdiven': 'Long Stairway',
      'stairs': 'Long Stairway',
      'yılan': 'Serpent Path',
      'snake': 'Serpent Path',
      'araba': 'Car Crash',
      'car': 'Car Crash',
      'alyans': 'Ringless Engagement',
      'ring': 'Ringless Engagement',
    }
    : {
      'su': 'Derin Sular',
      'uçmak': 'Göğe Yükseliş',
      'kapı': 'Eşik Kapısı',
      'ev': 'Sessiz Ev',
      'ayna': 'Ayna Odası',
      'merdiven': 'Uzun Merdiven',
      'yılan': 'Yılan Yolu',
      'araba': 'Araba Kazası',
      'alyans': 'Alyanssız Nişan',
    };

  for (const symbol of symbols || []) {
    const key = String(symbol || '').toLowerCase().trim();
    if (map[key]) return map[key];
    for (const mapKey of Object.keys(map)) {
      if (key.includes(mapKey)) return map[mapKey];
    }
  }

  const firstTheme = (themes || []).find(Boolean);
  if (firstTheme) {
    return String(firstTheme)
      .split(/\s+/)
      .slice(0, 3)
      .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
      .join(' ');
  }

  const words = String(dreamText || '')
    .replace(/[^\p{L}\p{N}\s]/gu, ' ')
    .split(/\s+/)
    .filter(Boolean)
    .slice(0, 3);
  if (!words.length) return (languageCode || '').startsWith('en') ? 'Untitled Dream' : 'Adsız Rüya';
  return words.map((w) => w.charAt(0).toUpperCase() + w.slice(1)).join(' ');
}

async function generateTitleAndMood({
  dreamText,
  interpretationText,
  symbols,
  themes,
  isPremium,
  languageCode,
}) {
  try {
    const raw = await callMistralText({
      model: mistralModel(isPremium),
      instruction:
        `Dream metadata generator. Return ONLY JSON: {"title":"...", "mood":"Curious|Calm|Anxious|Peaceful"}. Rules: title must be in ${languageName(languageCode)}, 2-4 words, concrete and evocative, no punctuation, no sentence. Mood must be one of the allowed values.`,
      text: `Dream text: ${dreamText}\nInterpretation: ${interpretationText}\nSymbols: ${(symbols || []).join(', ')}\nThemes: ${(themes || []).join(', ')}`,
    });

    const parsed = parseJsonObject(raw);
    const title = String(parsed.title || '').trim();
    const moodRaw = String(parsed.mood || '').trim();
    const allowed = new Set(['Curious', 'Calm', 'Anxious', 'Peaceful']);
    const mood = allowed.has(moodRaw) ? moodRaw : derivePrimaryMood(themes);

    if (!title) {
      return {
        autoTitle: fallbackAutoTitle(dreamText, symbols, themes, languageCode),
        primaryMood: mood,
      };
    }
    return { autoTitle: title, primaryMood: mood };
  } catch (e) {
    logger.warn('generateTitleAndMood fallback', e);
    return {
      autoTitle: fallbackAutoTitle(dreamText, symbols, themes, languageCode),
      primaryMood: derivePrimaryMood(themes),
    };
  }
}

async function extractSymbolsThemes(dreamText, interpretationText, isPremium, languageCode) {
  try {
    const raw = await callMistralText({
      model: mistralModel(isPremium),
      instruction:
        `Extract symbols and themes from dream text + interpretation. Return only JSON object as {"symbols": string[], "themes": string[]}. Use ${languageName(languageCode)} words and max 8 each.`,
      text: `Dream: ${dreamText}\nInterpretation: ${interpretationText}`,
    });

    const parsed = parseJsonObject(raw);
    return {
      symbols: Array.isArray(parsed.symbols) ? parsed.symbols.slice(0, 8) : [],
      themes: Array.isArray(parsed.themes) ? parsed.themes.slice(0, 8) : [],
    };
  } catch (e) {
    logger.warn('extractSymbolsThemes fallback', e);
    const lower = `${dreamText} ${interpretationText}`.toLowerCase();
    const symbols = FALLBACK_SYMBOLS.filter((s) => s.keys.some((k) => lower.includes(k)))
      .map((s) => ((languageCode || '').startsWith('en') ? s.en : s.tr))
      .slice(0, 8);
    return { symbols, themes: [] };
  }
}

exports.interpretDream = onRequest(
  { region: 'us-central1', timeoutSeconds: 120, secrets: [MISTRAL_API_KEY] },
  async (req, res) => {
    return wrapCors(req, res, async () => {
      const { uid, dreamText, source = 'text', chatId } = req.body || {};
      if (!uid || !dreamText || typeof dreamText !== 'string') {
        res.status(400).json({ error: 'uid and dreamText are required.' });
        return;
      }

      const userRef = db.collection('users').doc(uid);
      const userSnap = await userRef.get();
      if (!userSnap.exists) {
        res.status(404).json({ error: 'User not found.' });
        return;
      }

      const userData = userSnap.data() || {};
      const isPremium = Boolean(userData.isPremium);

      const today = todayYmd();
      const quotaDate = userData.freeQuotaDate || '';
      const quotaUsed = Number(userData.freeQuotaUsed || 0);

      if (!isPremium && quotaDate === today && quotaUsed >= 1) {
        res.status(403).json({ error: 'Daily free quota exceeded.' });
        return;
      }

      const dreamsSnap = await userRef
        .collection('dreams')
        .orderBy('createdAt', 'desc')
        .limit(5)
        .get();

      const recentDreams = dreamsSnap.docs
        .map((d) => d.data().dreamText || '')
        .filter(Boolean);
      const profile = userData.profile || {};
      const themesSummary = userData.aiSummary?.themesSummary || '';

      const developerPrompt = buildDeveloperPrompt({
        profile,
        themesSummary,
        recentDreams,
        newDreamText: dreamText,
      });
      const languageCode = await detectLanguageCode(dreamText, isPremium);

      const interpretationText =
        (await callMistralText({
          model: mistralModel(isPremium),
          instruction: buildSystemPrompt(languageCode),
          text: developerPrompt,
        })) ||
        ((languageCode || '').startsWith('en')
          ? 'I could not generate a gentle interpretation. Please try again.'
          : 'Rüyan için nazik bir yorum üretemedim, lütfen tekrar dene.');

      const { symbols, themes } = await extractSymbolsThemes(
        dreamText,
        interpretationText,
        isPremium,
        languageCode,
      );
      const { autoTitle, primaryMood } = await generateTitleAndMood({
        dreamText,
        interpretationText,
        symbols,
        themes,
        isPremium,
        languageCode,
      });

      const dreamRef = userRef.collection('dreams').doc();
      const resolvedChatId = chatId || userRef.collection('chats').doc().id;
      const chatRef = userRef.collection('chats').doc(resolvedChatId);

      const batch = db.batch();
      batch.set(
        dreamRef,
        {
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          source,
          dreamText,
          moodTag: null,
          autoTitle,
          primaryMood,
          languageCode,
          interpretation: {
            text: interpretationText,
            symbols,
            themes,
            cautionNoteShown: true,
          },
        },
        { merge: true },
      );

      batch.set(
        chatRef,
        {
          createdAt: admin.firestore.FieldValue.serverTimestamp(),
          lastUpdatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true },
      );

      batch.set(chatRef.collection('messages').doc(), {
        role: 'user',
        text: dreamText,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        linkedDreamId: dreamRef.id,
      });

      batch.set(chatRef.collection('messages').doc(), {
        role: 'assistant',
        text: interpretationText,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        linkedDreamId: dreamRef.id,
      });

      if (!isPremium) {
        const nextUsed = quotaDate === today ? quotaUsed + 1 : 1;
        batch.set(
          userRef,
          {
            freeQuotaDate: today,
            freeQuotaUsed: nextUsed,
          },
          { merge: true },
        );
      }

      if (themes.length) {
        batch.set(
          userRef,
          {
            aiSummary: {
              themesSummary: themes.join(', '),
              updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            },
          },
          { merge: true },
        );
      }

      await batch.commit();

      const freeQuotaUsed = !isPremium
        ? quotaDate === today
          ? quotaUsed + 1
          : 1
        : quotaUsed;

      res.json({
        interpretationText,
        symbols,
        themes,
        autoTitle,
        primaryMood,
        languageCode,
        dreamId: dreamRef.id,
        chatId: resolvedChatId,
        freeQuotaUsed,
      });
    });
  },
);

exports.transcribeAudio = onRequest(
  { region: 'us-central1', timeoutSeconds: 180, secrets: [MISTRAL_API_KEY] },
  async (req, res) => {
    return wrapCors(req, res, async () => {
      const { uid, audioBase64, storagePath } = req.body || {};
      if (!uid) {
        res.status(400).json({ error: 'uid is required.' });
        return;
      }

      const userSnap = await db.collection('users').doc(uid).get();
      if (!userSnap.exists) {
        res.status(404).json({ error: 'User not found.' });
        return;
      }
      const isPremium = Boolean(userSnap.data()?.isPremium);
      if (!isPremium) {
        res.status(403).json({ error: 'Premium required.' });
        return;
      }

      if (!audioBase64 && !storagePath) {
        res.status(400).json({ error: 'audioBase64 or storagePath is required.' });
        return;
      }

      const ext = '.m4a';
      const tmpFilePath = path.join(os.tmpdir(), `dream-audio-${Date.now()}${ext}`);
      let mimeType = 'audio/mp4';

      if (storagePath) {
        const bucket = storage.bucket();
        await bucket.file(storagePath).download({ destination: tmpFilePath });
      } else {
        const match = String(audioBase64).match(/^data:(audio\/[^;]+);base64,(.+)$/);
        if (match) {
          mimeType = match[1];
          fs.writeFileSync(tmpFilePath, Buffer.from(match[2], 'base64'));
        } else {
          fs.writeFileSync(tmpFilePath, Buffer.from(String(audioBase64), 'base64'));
        }
      }

      const audioBytes = fs.readFileSync(tmpFilePath).toString('base64');
      try {
        fs.unlinkSync(tmpFilePath);
      } catch (e) {
        logger.warn('tmp file cleanup failed', e);
      }

      const text = await callMistralAudioTranscription({
        model: process.env.MISTRAL_MODEL_STT || 'voxtral-mini-latest',
        mimeType,
        audioBase64: audioBytes,
      });

      res.json({ text: text || '' });
    });
  },
);
