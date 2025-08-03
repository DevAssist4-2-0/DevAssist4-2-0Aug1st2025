const { v4: uuidv4 } = require('uuid');// cleanScan.js - scans code for suspicious keywords/imports

const fs = require('fs');
const path = require('path');

const suspiciousKeywords = [
  'google',
  'firebase',
  'gemini',
  'meta',
  'genai',
  'azure',
  'vertex',
  'replit',
  'googleapis',
  'gcp',
];

const ignoredDirs = [
  'node_modules',
  '.git',
  'dist',
  'build',
  '__pycache__'
];

function scanDir(dir) {
  const files = fs.readdirSync(dir);
  for (const file of files) {
    const fullPath = path.join(dir, file);
    const stat = fs.statSync(fullPath);

    if (stat.isDirectory()) {
      if (!ignoredDirs.includes(file)) scanDir(fullPath);
    } else if (
      fullPath.endsWith('.js') ||
      fullPath.endsWith('.ts') ||
      fullPath.endsWith('.json') ||
      fullPath.endsWith('.py') ||
      fullPath.endsWith('.swift')
    ) {
      const content = fs.readFileSync(fullPath, 'utf8').toLowerCase();
      suspiciousKeywords.forEach((keyword) => {
        if (content.includes(keyword)) {
          console.log(`⚠️  Found "${keyword}" in ${fullPath}`);
        }
      });
    }
  }
}

const targetDir = process.argv[2] || '.';
console.log(`🔍 Scanning directory: ${targetDir}\n`);
scanDir(targetDir);
console.log('\n✅ Scan complete.');
