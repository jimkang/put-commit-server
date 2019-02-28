#!/usr/bin/env node

/* global process */

var PutCommitServerCore = require('put-commit-server-core');
var logFormat = require('log-format');
var config = require('./config');

const port = 6666;

PutCommitServerCore(
  {
    gitDir:
      process.env.GITDIR || '/usr/share/nginx/html/smidgeo.com/story-beat-data',
    secret: config.secret
  },
  useServerCore
);

function useServerCore(error, server) {
  if (error) {
    process.stderr.write(logFormat(error.message, error.stack));
    process.exit(1);
    return;
  }

  server.listen(port, onReady);

  function onReady(error) {
    if (error) {
      process.stderr.write(logFormat(error.message, error.stack));
    } else {
      process.stdout.write(logFormat(server.name, 'listening at', server.url));
    }
  }
}
