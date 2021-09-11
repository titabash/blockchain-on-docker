tmux kill-session -t web_app > /dev/null 2>&1
docker-compose down --rmi all --volumes --remove-orphans
