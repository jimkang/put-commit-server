include config.mk

HOMEDIR = $(shell pwd)
SSHCMD = ssh $(USER)@$(SERVER)
PRIVSSHCMD = ssh $(PRIVUSER)@$(SERVER)
PROJECTNAME = put-commit-server
APPDIR = /opt/$(PROJECTNAME)
TESTGITDIR = tests/test-git-dir
GITDIR = /usr/share/nginx/html/smidgeo.com/story-beat-data

pushall: update-remote
	git push origin master

run:
	GITDIR=$(GITDIR) node start-$(PROJECTNAME).js

sync:
	rsync -a $(HOMEDIR) $(USER)@$(SERVER):/opt/ --exclude node_modules/ \
	  --omit-dir-times --no-perms
	$(SSHCMD) "cd /opt/$(PROJECTNAME) && npm install"

restart-remote:
	$(PRIVSSHCMD) "service $(PROJECTNAME) restart"

start-service:
	$(PRIVSSHCMD) "service $(PROJECTNAME) start"

stop-service:
	$(PRIVSSHCMD) "service $(PROJECTNAME) stop"

set-permissions:
	$(PRIVSSHCMD) "chmod +x $(APPDIR)/start-$(PROJECTNAME).js"

update-remote: sync set-permissions restart-remote

install-service:
	$(PRIVSSHCMD) "cp $(APPDIR)/$(PROJECTNAME).service /etc/systemd/system && \
	systemctl enable $(PROJECTNAME)"

set-up-git-dir:
	$(SSHCMD) "mkdir -p $(GITDIR)"
	$(SSHCMD) "cd $(GITDIR) && \
	  git init && \
	  touch git-stub && \
	  git add . && \
	  git config user.name "Jim Kang" && \
	  git config user.email "jimkang@gmail.com" && \
	  git commit -a -m\"Started.\" --author \"Jim Kang <jimkang@gmail.com>\" && \
	  git remote add origin git@github.com:jimkang/story-beat-data.git"

set-up-app-dir:
	$(SSHCMD) "mkdir -p $(APPDIR)"

initial-setup: set-up-app-dir set-up-git-dir sync set-permissions install-service

check-status:
	$(SSHCMD) "systemctl status $(PROJECTNAME)"

check-log:
	$(SSHCMD) "journalctl -r -u $(PROJECTNAME)"

prettier:
	prettier --single-quote --write "**/*.js"
