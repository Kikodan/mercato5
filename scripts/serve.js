const http = require('http');
const https = require('https');
const fs = require('fs');
const path = require('path');
const os = require('os');

const HTTP_PORT = 8000;
const HTTPS_PORT = 8443;
const WEB_DIR = path.join(__dirname, '..', 'build', 'web');
const PFX_PATH = path.join(__dirname, 'cert.pfx');

const MIME_TYPES = {
    '.html': 'text/html; charset=utf-8',
    '.js': 'application/javascript; charset=utf-8',
    '.json': 'application/json; charset=utf-8',
    '.wasm': 'application/wasm',
    '.pck': 'application/octet-stream',
    '.png': 'image/png',
    '.jpg': 'image/jpeg',
    '.jpeg': 'image/jpeg',
    '.svg': 'image/svg+xml',
    '.ico': 'image/x-icon',
    '.css': 'text/css'
};

function getLocalIp() {
    const interfaces = os.networkInterfaces();
    for (const name of Object.keys(interfaces)) {
        for (const iface of interfaces[name]) {
            if (iface.family === 'IPv4' && !iface.internal) {
                return iface.address;
            }
        }
    }
    return 'localhost';
}

function handleRequest(req, res) {
    let reqPath = decodeURIComponent(req.url.split('?')[0]);
    if (reqPath === '/' || reqPath === '') {
        reqPath = '/index.html';
    }

    const filePath = path.join(WEB_DIR, reqPath);

    if (!filePath.startsWith(WEB_DIR)) {
        res.writeHead(403);
        res.end('Access Denied');
        return;
    }

    fs.stat(filePath, (err, stats) => {
        if (err || !stats.isFile()) {
            res.writeHead(404, { 'Content-Type': 'text/plain' });
            res.end('404 Not Found');
            return;
        }

        const ext = path.extname(filePath).toLowerCase();
        const contentType = MIME_TYPES[ext] || 'application/octet-stream';

        const headers = {
            'Content-Type': contentType,
            'Content-Length': stats.size,
            'Cross-Origin-Opener-Policy': 'same-origin',
            'Cross-Origin-Embedder-Policy': 'require-corp',
            'Access-Control-Allow-Origin': '*',
            'Cache-Control': 'no-cache'
        };

        res.writeHead(200, headers);
        fs.createReadStream(filePath).pipe(res);
    });
}

const localIp = getLocalIp();

// Start HTTP server
const httpServer = http.createServer(handleRequest);
httpServer.listen(HTTP_PORT, '0.0.0.0');

// Start HTTPS server if cert exists
let hasHttps = false;
if (fs.existsSync(PFX_PATH)) {
    try {
        const pfx = fs.readFileSync(PFX_PATH);
        const httpsServer = https.createServer({ pfx, passphrase: 'mercato' }, handleRequest);
        httpsServer.listen(HTTPS_PORT, '0.0.0.0');
        hasHttps = true;
    } catch (e) {
        console.error('Erreur HTTPS:', e.message);
    }
}

console.log('\n=============================================================');
console.log('⚽ MERCATO 5 - SERVEUR MOBILE OPÉRATIONNEL (iOS & Android)');
console.log('=============================================================');
console.log('\n📱 Pour jouer sur votre iPhone / iPad ou téléphone Android :');
console.log('   1. Connectez votre téléphone au même réseau Wi-Fi que ce PC.');
console.log('   2. Ouvrez Safari (iPhone) ou Chrome (Android).');
console.log('   3. Tapez l\'une des adresses suivantes :');
console.log('\n      👉  http://' + localIp + ':' + HTTP_PORT);
if (hasHttps) {
    console.log('      👉  https://' + localIp + ':' + HTTPS_PORT + ' (Recommandé sur iOS Safari)\n');
    console.log('   ℹ️  Sur HTTPS avec certificat local :');
    console.log('      • Safari affichera "Ce site web n\'est pas sécurisé" (normal en réseau local).');
    console.log('      • Touchez "Afficher les détails" en bas, puis "Visiter ce site web".');
}
console.log('\n   4. Pour passer en PLEIN ÉCRAN PAYSAGE (sur iPhone) :');
console.log('      • Touchez le bouton \'Partager\' (carré avec flèche)');
console.log('      • Choisissez \'Sur l\'écran d\'accueil\'');
console.log('      • Lancez Mercato 5 comme une vraie application !');
console.log('\n💻 Sur ce PC : http://localhost:' + HTTP_PORT);
console.log('=============================================================\n');