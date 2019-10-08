const http = require('http');
const fs = require('fs');
const path = require('path');
const fetch = require('@dillonchr/fetch');
const async = require('async');
const { exec } = require('child_process');

const getFileName = () => path.join(__dirname, 'frames', `fr-${new Date().getTime()}.jpg`);

const getCrissyFieldCam = (done) => {
    fetch({
        url: `http://173.164.254.148/ptz.cgi?doc=East%20Beach%20Webcam&xml=1&cmd=open&version=20100917&kind=ctl`
    }, (err, body) => {
        if (err) {
            done(err);
        } else {
            try {
                const [ignore, id] = body.match(/key="id" value="([^"]+)"/);
                done(null, `http://173.164.254.148/vid.cgi?id=${id}&doc=East%20Beach%20Webcam&i=1`);
            } catch(err) {
                done(err);
            }
        }
    });
};

const download = (url, fn) => {
    const filename = getFileName();
    const file = fs.createWriteStream(filename);
    http.get(url, (res) => {
        res.pipe(file);
        file.on('finish', () => {
            setTimeout(() => file.close(fn), 1000);
        });
    })
        .on('error', (err) => {
            fs.unlink(filename);
            fn(err);
        });
};

const downloadFrame = (prefix, fn) => {
    const url = `${prefix}&r=${Math.random()}`;
    download(url, fn);
};

const downloadFrames = (n) => {
    getCrissyFieldCam((err, prefix) => {
        if (!prefix && err) {
            return console.error('FAILED TO GET URL PREFIX', err);
        }

        console.log('GOTCHA BOY', prefix);
        const todo = Array(n)
            .fill(0)
            .map(() => fn => downloadFrame(prefix, fn));
        async.series(todo, (err) => {
            if (err) {
                return console.error('FAILED TO DOWNLOAD URL', url, err);
            }
            console.log('GOTCHA');
            exec('./gifmake.sh', (err, stdErr, stdOut) => {
                if (err) {
                    console.error('ERROR YO', err);
                } else if (stdErr) {
                    console.error('STD ERROR', stdErr);
                } else {
                    console.log('IDK', stdOut);
                }
            });
        });
    });
};

downloadFrames(10);
