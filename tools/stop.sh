tmux kill-session -t $(basename `git rev-parse --show-toplevel`)
docker-compose stop
