const http = require('http');
const url = require('url');

const PORT = 3000;

// Sample members data with valid avatar URLs
const members = [
  {
    id: "m001",
    firstName: "Emma",
    lastName: "Johnson",
    birthYear: 2010,
    relationship: "Daughter",
    avatar: "https://i.pravatar.cc/150?img=1",
    status: "active",
    screenTimeEnabled: true
  },
  {
    id: "m002",
    firstName: "Liam",
    lastName: "Smith",
    birthYear: 2008,
    relationship: "Son", 
    avatar: "https://i.pravatar.cc/150?img=2",
    status: "active",
    screenTimeEnabled: false
  },
  {
    id: "m003",
    firstName: "Sophia",
    lastName: "Williams",
    birthYear: 2012,
    relationship: "Daughter",
    avatar: "https://i.pravatar.cc/150?img=3",
    status: "inactive",
    screenTimeEnabled: true
  },
  {
    id: "m004", 
    firstName: "Noah",
    lastName: "Brown",
    birthYear: 2009,
    relationship: "Son",
    avatar: "https://i.pravatar.cc/150?img=4",
    status: "active",
    screenTimeEnabled: false
  }
];

const server = http.createServer((req, res) => {
  const parsedUrl = url.parse(req.url, true);
  const path = parsedUrl.pathname;
  const method = req.method;

  // CORS headers
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, POST, PATCH, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type');

  if (method === 'OPTIONS') {
    res.writeHead(200);
    res.end();
    return;
  }

  console.log(`${method} ${path}`);

  // Routes
  if (path === '/members' && method === 'GET') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify(members));
  }
  else if (path.startsWith('/members/') && method === 'PATCH') {
    const id = path.split('/')[2];
    let body = '';
    
    req.on('data', chunk => {
      body += chunk.toString();
    });
    
    req.on('end', () => {
      try {
        const updates = JSON.parse(body);
        const memberIndex = members.findIndex(m => m.id === id);
        
        if (memberIndex === -1) {
          res.writeHead(404, { 'Content-Type': 'application/json' });
          res.end(JSON.stringify({ error: 'Member not found' }));
          return;
        }
        
        // Update member
        members[memberIndex] = { ...members[memberIndex], ...updates };
        
        res.writeHead(200, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify(members[memberIndex]));
      } catch (error) {
        res.writeHead(400, { 'Content-Type': 'application/json' });
        res.end(JSON.stringify({ error: 'Invalid JSON' }));
      }
    });
  }
  else if (path === '/auth/login' && method === 'POST') {
    res.writeHead(200, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({
      token: 'mock_jwt_token_' + Date.now(),
      user: { email: 'user@example.com' }
    }));
  }
  else {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Route not found' }));
  }
});

server.listen(PORT, () => {
  console.log(`Mock server running at http://localhost:${PORT}`);
  console.log('Available endpoints:');
  console.log('  GET  /members');
  console.log('  PATCH /members/:id');
  console.log('  POST /auth/login');
});