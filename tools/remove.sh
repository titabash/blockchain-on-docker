tmux kill-session -t $(basename `git rev-parse --show-toplevel`)
docker-compose down --rmi all --volumes --remove-orphans
