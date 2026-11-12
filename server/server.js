// Serveur simulé de CampusFlow : json-server + faux /login (séance 7).
//
//   POST /login   {"email", "motDePasse"} → 200 {"jeton", "utilisateur"}
//                                        → 401 identifiants incorrects
//   Toutes les autres routes exigent  Authorization: Bearer <jeton>
//   sinon                              → 401 (jeton absent ou expiré)
//
// Le jeton est un JWT signé (HS256) avec une expiration. Serveur de TP :
// secret en dur et mots de passe en clair, jamais en production.
//
//   npm start                     port 3000, jeton valable 1 h
//   JETON_DUREE=30 npm start      jeton valable 30 s (tester l'expiration)

const crypto = require('crypto');
const path = require('path');
const jsonServer = require('json-server');

const PORT = Number(process.env.PORT ?? 3000);
const DUREE = Number(process.env.JETON_DUREE ?? 3600); // secondes
const SECRET = 'campusflow-tp-seance-7';

const base64url = (data) => Buffer.from(data).toString('base64url');
const signer = (contenu) =>
  crypto.createHmac('sha256', SECRET).update(contenu).digest('base64url');

function creerJeton(utilisateur) {
  const entete = base64url(JSON.stringify({ alg: 'HS256', typ: 'JWT' }));
  const charge = base64url(JSON.stringify({
    sub: utilisateur.id,
    nom: utilisateur.nom,
    exp: Math.floor(Date.now() / 1000) + DUREE,
  }));
  return `${entete}.${charge}.${signer(`${entete}.${charge}`)}`;
}

/** Renvoie la charge du jeton s'il est bien signé et non expiré, sinon null. */
function verifierJeton(jeton) {
  const [entete, charge, signature] = (jeton ?? '').split('.');
  if (!entete || !charge || !signature) return null;
  const attendue = signer(`${entete}.${charge}`);
  if (signature.length !== attendue.length ||
      !crypto.timingSafeEqual(Buffer.from(signature), Buffer.from(attendue))) {
    return null;
  }
  try {
    const contenu = JSON.parse(Buffer.from(charge, 'base64url').toString());
    return contenu.exp > Date.now() / 1000 ? contenu : null;
  } catch {
    return null;
  }
}

const server = jsonServer.create();
const router = jsonServer.router(path.join(__dirname, 'db.json'));

server.use(jsonServer.defaults());
server.use(jsonServer.bodyParser);

server.post('/login', (req, res) => {
  const { email, motDePasse } = req.body ?? {};
  if (!email || !motDePasse) {
    return res.status(400).json({ message: 'Adresse et mot de passe requis.' });
  }
  const trouve = router.db
    .get('utilisateurs')
    .find((u) => u.email.toLowerCase() === String(email).trim().toLowerCase())
    .value();
  if (!trouve || trouve.motDePasse !== motDePasse) {
    return res.status(401).json({ message: 'Adresse ou mot de passe incorrect.' });
  }
  const { motDePasse: _cache, ...utilisateur } = trouve;
  res.json({ jeton: creerJeton(utilisateur), utilisateur });
});

// Toutes les autres routes : jeton obligatoire.
server.use((req, res, next) => {
  const [type, jeton] = (req.headers.authorization ?? '').split(' ');
  if (type !== 'Bearer' || !verifierJeton(jeton)) {
    return res.status(401).json({ message: 'Jeton absent ou expiré.' });
  }
  next();
});

// Les comptes (mots de passe) ne sont jamais exposés : ni la collection,
// ni l'instantané complet `/db` de json-server.
// Toute requête qui vise `utilisateurs` est refusée, y compris par une
// route imbriquée (`/cours/dm/utilisateurs`) ou `_embed` / `_expand`.
server.use((req, res, next) => {
  const cible = decodeURIComponent(req.originalUrl).toLowerCase();
  if (req.path === '/db' || cible.includes('utilisateur')) {
    return res.status(403).json({ message: 'Interdit.' });
  }
  next();
});

// Filet de sécurité : aucun `motDePasse` dans une réponse, quelle que soit
// la route (`_embed`, `_expand`…).
const sansMotDePasse = (valeur) => {
  if (Array.isArray(valeur)) return valeur.map(sansMotDePasse);
  if (valeur && typeof valeur === 'object') {
    const { motDePasse: _cache, ...reste } = valeur;
    return Object.fromEntries(
      Object.entries(reste).map(([cle, v]) => [cle, sansMotDePasse(v)]));
  }
  return valeur;
};
router.render = (req, res) => res.jsonp(sansMotDePasse(res.locals.data));

server.use(router);

server.listen(PORT, '0.0.0.0', () => {
  console.log(`API CampusFlow : http://localhost:${PORT} (émulateur Android : http://10.0.2.2:${PORT})`);
  console.log(`Jeton valable ${DUREE} s. Compte de démo : ibrahim.kabore@universite.bf / campus2026`);
});
