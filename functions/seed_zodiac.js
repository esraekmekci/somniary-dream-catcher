/**
 * Seed script for populating the zodiac_signs collection in Firestore.
 *
 * Usage:
 *   cd functions
 *   node seed_zodiac.js
 *
 * Prerequisites:
 *   - Firebase Admin SDK (already available via functions/package.json)
 *   - A service account key OR the GOOGLE_APPLICATION_CREDENTIALS env variable set
 *     OR run from a machine authenticated with `firebase login` + `gcloud auth`
 *
 * If you don't have a service account key, you can use the Firebase emulator
 * or set GOOGLE_APPLICATION_CREDENTIALS to a valid service account JSON.
 */

const admin = require("firebase-admin");

// Initialize – uses Application Default Credentials when no key file is given.
if (!admin.apps.length) {
  admin.initializeApp({
    projectId: "somniary-dream-catcher",
  });
}

const db = admin.firestore();

const zodiacSigns = [
  {
    name: "Aries",
    symbol: "♈",
    element: "Fire",
    dateRange: "March 21 – April 19",
    description:
      "Aries is the first sign of the zodiac and is ruled by Mars, the planet of action, energy, and desire. " +
      "People born under this sign are known for their bold, ambitious, and pioneering spirit. They are natural leaders who thrive on challenges and are always ready to take initiative. " +
      "Aries individuals are fiercely independent, courageous, and enthusiastic about life. They have an infectious energy that inspires those around them. " +
      "However, their impulsive nature can sometimes lead to hasty decisions. They can be competitive and occasionally impatient, wanting results immediately. " +
      "In relationships, Aries are passionate and loyal partners who value honesty and directness. " +
      "Their ruling element is Fire, which reflects their warm, dynamic, and assertive personality. " +
      "Aries dreams often reflect themes of adventure, competition, and the desire to conquer new frontiers.",
  },
  {
    name: "Taurus",
    symbol: "♉",
    element: "Earth",
    dateRange: "April 20 – May 20",
    description:
      "Taurus is the second sign of the zodiac and is ruled by Venus, the planet of love, beauty, and pleasure. " +
      "Those born under Taurus are known for their reliability, patience, and love of comfort and luxury. They are grounded, practical individuals who value stability and security above all. " +
      "Taurus people have a strong connection to the physical world — they appreciate fine food, art, music, and the beauty of nature. " +
      "They are incredibly determined and persistent; once they set their mind on something, they follow through with unwavering dedication. " +
      "On the flip side, Taurus can be stubborn and resistant to change. They prefer routine and can become possessive in relationships. " +
      "In love, they are deeply devoted, sensual, and seek long-term commitment. " +
      "Their Earth element grounds them, making them dependable and trustworthy friends and partners. " +
      "Taurus dreams often feature themes of abundance, nature, sensory experiences, and the search for inner peace.",
  },
  {
    name: "Gemini",
    symbol: "♊",
    element: "Air",
    dateRange: "May 21 – June 20",
    description:
      "Gemini is the third sign of the zodiac and is ruled by Mercury, the planet of communication, intellect, and adaptability. " +
      "Geminis are known for their wit, curiosity, and dual nature. They are social butterflies who can effortlessly navigate different social circles and adapt to any situation. " +
      "Their minds are always active, seeking new information, experiences, and conversations. They are excellent communicators, storytellers, and often have a talent for languages. " +
      "Geminis are versatile and quick learners, but their restless nature can make them seem inconsistent or superficial to others. " +
      "They crave mental stimulation and can become bored easily if not challenged. " +
      "In relationships, Geminis value intellectual connection and need a partner who can keep up with their ever-evolving interests. " +
      "Their Air element fuels their need for freedom, variety, and social connection. " +
      "Gemini dreams tend to be vivid, complex, and often involve communication, travel, or encounters with multiple characters.",
  },
  {
    name: "Cancer",
    symbol: "♋",
    element: "Water",
    dateRange: "June 21 – July 22",
    description:
      "Cancer is the fourth sign of the zodiac and is ruled by the Moon, governing emotions, intuition, and the subconscious mind. " +
      "Cancers are deeply emotional, nurturing, and protective individuals. They have an extraordinary ability to sense the feelings of others and provide comfort and care. " +
      "Home and family are at the center of a Cancer's world. They create warm, safe spaces and cherish their loved ones above all else. " +
      "Cancers have a rich inner world and are often highly imaginative and creative. They are drawn to art, music, and storytelling. " +
      "However, their sensitivity can also make them moody, clingy, or overly cautious. They tend to retreat into their shell when feeling threatened. " +
      "In love, Cancers are devoted, compassionate, and seek deep emotional bonds. " +
      "Their Water element enhances their empathy, intuition, and emotional depth. " +
      "Cancer dreams are often vivid and emotionally charged, frequently involving themes of home, family, water, and the past.",
  },
  {
    name: "Leo",
    symbol: "♌",
    element: "Fire",
    dateRange: "July 23 – August 22",
    description:
      "Leo is the fifth sign of the zodiac and is ruled by the Sun, the center of our solar system — symbolizing vitality, self-expression, and creativity. " +
      "Leos are natural-born leaders with a magnetic personality that draws others to them. They are generous, warm-hearted, and love being in the spotlight. " +
      "Confidence and charisma are their hallmarks. Leos have a strong sense of self and take pride in their achievements and appearance. " +
      "They are fiercely loyal to their friends and family and will go to great lengths to protect and support their loved ones. " +
      "However, Leos can be prone to arrogance, stubbornness, and a need for constant admiration. Their pride can sometimes get in the way of compromise. " +
      "In relationships, Leos are passionate, romantic, and love grand gestures of affection. " +
      "Their Fire element fuels their enthusiasm, creativity, and desire to make a lasting impact on the world. " +
      "Leo dreams often feature themes of recognition, performance, royalty, and the desire to shine.",
  },
  {
    name: "Virgo",
    symbol: "♍",
    element: "Earth",
    dateRange: "August 23 – September 22",
    description:
      "Virgo is the sixth sign of the zodiac and is ruled by Mercury, the planet of communication and analysis. " +
      "Virgos are known for their meticulous attention to detail, analytical minds, and deep sense of duty. They are perfectionists who strive for excellence in everything they do. " +
      "Practical, organized, and hardworking, Virgos excel at problem-solving and have a talent for finding efficient solutions. " +
      "They have a genuine desire to help others and often put the needs of others before their own. This makes them incredibly reliable friends and colleagues. " +
      "However, their perfectionism can lead to excessive worry, self-criticism, and difficulty relaxing. They may set impossibly high standards for themselves and others. " +
      "In relationships, Virgos are thoughtful, attentive, and show love through acts of service. " +
      "Their Earth element keeps them grounded, realistic, and focused on tangible results. " +
      "Virgo dreams often involve themes of order, problem-solving, health, and the pursuit of improvement.",
  },
  {
    name: "Libra",
    symbol: "♎",
    element: "Air",
    dateRange: "September 23 – October 22",
    description:
      "Libra is the seventh sign of the zodiac and is ruled by Venus, the planet of love, harmony, and beauty. " +
      "Libras are defined by their pursuit of balance, justice, and harmony in all aspects of life. They are diplomatic, charming, and have a natural ability to see multiple perspectives. " +
      "Aesthetics and beauty are deeply important to Libras. They appreciate art, design, and elegance, often surrounding themselves with beautiful environments. " +
      "They are social beings who thrive in partnerships and collaborations. Libras are excellent mediators and peacemakers. " +
      "However, their desire to please everyone can lead to indecisiveness, people-pleasing, and avoidance of conflict. They may struggle to assert their own needs. " +
      "In relationships, Libras are romantic, devoted, and seek a true partnership of equals. " +
      "Their Air element enhances their intellectual curiosity, communication skills, and need for social connection. " +
      "Libra dreams often feature themes of relationships, beauty, balance, and the search for fairness and justice.",
  },
  {
    name: "Scorpio",
    symbol: "♏",
    element: "Water",
    dateRange: "October 23 – November 21",
    description:
      "Scorpio is the eighth sign of the zodiac and is ruled by Pluto, the planet of transformation, power, and rebirth, along with Mars. " +
      "Scorpios are known for their intensity, depth, and magnetic presence. They are the most emotionally powerful sign of the zodiac, experiencing life with extraordinary passion. " +
      "They possess incredible willpower, determination, and a desire to uncover hidden truths. Scorpios are drawn to mysteries and have a natural talent for research and investigation. " +
      "Loyalty is paramount to Scorpios — they form deep, unbreakable bonds with those they trust. However, betrayal is something they rarely, if ever, forgive. " +
      "Their shadow side includes tendencies toward jealousy, possessiveness, and emotional manipulation. They can be secretive and distrustful. " +
      "In love, Scorpios are deeply devoted, intensely passionate, and seek all-or-nothing connections. " +
      "Their Water element amplifies their emotional depth, intuition, and transformative nature. " +
      "Scorpio dreams are often intense and powerful, featuring themes of transformation, secrets, death and rebirth, and deep emotional exploration.",
  },
  {
    name: "Sagittarius",
    symbol: "♐",
    element: "Fire",
    dateRange: "November 22 – December 21",
    description:
      "Sagittarius is the ninth sign of the zodiac and is ruled by Jupiter, the planet of expansion, luck, and wisdom. " +
      "Sagittarians are the adventurers and philosophers of the zodiac. They are driven by an insatiable curiosity and a deep desire to explore the world — both physically and intellectually. " +
      "They are optimistic, enthusiastic, and have a wonderful sense of humor. Their positive energy and open-mindedness make them delightful companions. " +
      "Freedom is essential to Sagittarians; they resist anything that feels confining or restrictive. They value honesty and are known for their blunt, straightforward communication. " +
      "However, their love of freedom can make them commitment-phobic, and their bluntness can sometimes come across as tactless. They may struggle with follow-through. " +
      "In relationships, Sagittarians need a partner who respects their independence and shares their love of adventure. " +
      "Their Fire element fuels their passion for life, exploration, and the quest for meaning. " +
      "Sagittarius dreams often involve travel, adventure, discovery, and the pursuit of higher knowledge and truth.",
  },
  {
    name: "Capricorn",
    symbol: "♑",
    element: "Earth",
    dateRange: "December 22 – January 19",
    description:
      "Capricorn is the tenth sign of the zodiac and is ruled by Saturn, the planet of discipline, responsibility, and structure. " +
      "Capricorns are the most ambitious and hardworking sign of the zodiac. They are driven by a deep desire to achieve their goals and build a lasting legacy. " +
      "They are practical, disciplined, and patient, understanding that success is a marathon, not a sprint. Capricorns have excellent organizational skills and a strong sense of duty. " +
      "They value tradition, reputation, and social status. Behind their serious exterior lies a dry, witty sense of humor and a surprisingly warm heart. " +
      "However, Capricorns can be overly rigid, pessimistic, and may prioritize work over personal relationships. They may struggle to express emotions openly. " +
      "In love, Capricorns are loyal, committed, and build relationships with the same care and attention they bring to their careers. " +
      "Their Earth element grounds them, providing stability, persistence, and a realistic approach to life. " +
      "Capricorn dreams often feature themes of ambition, mountains, authority, achievement, and the journey toward their goals.",
  },
  {
    name: "Aquarius",
    symbol: "♒",
    element: "Air",
    dateRange: "January 20 – February 18",
    description:
      "Aquarius is the eleventh sign of the zodiac and is ruled by Uranus, the planet of innovation, rebellion, and originality, along with Saturn. " +
      "Aquarians are the visionaries and humanitarians of the zodiac. They are progressive, independent thinkers who value individuality and are always looking toward the future. " +
      "They have a unique perspective on the world and often champion unconventional ideas and causes. Aquarians are deeply concerned with social justice and the collective good. " +
      "They are intellectual, inventive, and excel in fields that involve technology, science, and social reform. " +
      "However, Aquarians can sometimes come across as emotionally detached, aloof, or unpredictable. They may prioritize intellectual connection over emotional intimacy. " +
      "In relationships, Aquarians value friendship, equality, and mental stimulation. They need a partner who respects their need for independence. " +
      "Their Air element fuels their innovative thinking, communication skills, and desire for freedom. " +
      "Aquarius dreams often involve futuristic themes, community, technology, flying, and visions of a better world.",
  },
  {
    name: "Pisces",
    symbol: "♓",
    element: "Water",
    dateRange: "February 19 – March 20",
    description:
      "Pisces is the twelfth and final sign of the zodiac and is ruled by Neptune, the planet of dreams, imagination, and spirituality. " +
      "Pisces are the dreamers and mystics of the zodiac. They possess an extraordinary depth of empathy, compassion, and emotional sensitivity that allows them to connect with others on a soul level. " +
      "They are highly intuitive, creative, and artistic. Many Pisces are drawn to music, poetry, film, and other forms of creative expression. " +
      "Pisces have a rich inner world and a vivid imagination. They are naturally spiritual and often feel a deep connection to the unseen realms. " +
      "However, their sensitivity can make them vulnerable to escapism, emotional overwhelm, and difficulty setting boundaries. They may absorb the emotions of others like a sponge. " +
      "In love, Pisces are deeply romantic, selfless, and seek a transcendent, soulful connection. " +
      "Their Water element enhances their intuition, emotional depth, and capacity for unconditional love. " +
      "Pisces dreams are often the most vivid and symbolic of all the signs, featuring themes of water, spirituality, healing, and journeys through the subconscious.",
  },
];

async function seed() {
  const batch = db.batch();

  for (const sign of zodiacSigns) {
    const ref = db.collection("zodiac_signs").doc(sign.name);
    batch.set(ref, sign);
  }

  await batch.commit();
  console.log("✅ Successfully seeded 12 zodiac signs into Firestore.");
}

seed().catch((err) => {
  console.error("❌ Seeding failed:", err);
  process.exit(1);
});
