
```bash
mkdir ~/mm-config ~/mm-modules
docker-compose --env-file .env -f docker-compose.yml up -d
touch ~/.docker.xauth
xauth nlist $DISPLAY | sed -e 's/^..../ffff/' | xauth -f ~/.docker.xauth nmerge -
```