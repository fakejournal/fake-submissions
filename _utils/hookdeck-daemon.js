/*
    node _utils/hookdeck-daemon.js

    Use this daemon script to listen 
*/


const http = require('http');
const { exec } = require('child_process');

const PORT = 12287;

const server = http.createServer((req, res) => {
    // Only trigger on POST requests (GitHub webhooks are POSTs)
    if (req.method === 'POST') {
        console.log('Received webhook from Hookdeck! Running "_utils/hookdeck-on-push.sh" ...');

        // Execute your bash script
        exec('bash _utils/hookdeck-on-push.sh', (error, stdout, stderr) => {
            if (error) {
                console.error(`Error executing script: ${error.message}`);
                return;
            }
            if (stderr) console.error(`Script stderr: ${stderr}`);
            console.log(`Script stdout:\n${stdout}`);
        });

        res.writeHead(200, { 'Content-Type': 'text/plain' });
        res.end('Script triggered successfully.');
    } else {
        res.writeHead(404);
        res.end();
    }
});

server.listen(PORT, () => {
    console.log(`Local webhook handler listening on port ${PORT}`);
});
