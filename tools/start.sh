tmux kill-session -t $(basename `git rev-parse --show-toplevel`) > /dev/null 2>&1
docker-compose up -d
array=$(docker ps --format '{{.Names}}' --filter 'name=_bc')
NUM=0
for var in ${array[@]}
do
    if [ $NUM = 0 ]; then
        tmux new-session -s $(basename `git rev-parse --show-toplevel`)  -n ${var} -d "docker exec -it ${var} /bin/bash";
    else
        tmux new-window  -t $(basename `git rev-parse --show-toplevel`):${NUM} -n ${var}  "docker exec -it ${var} /bin/bash";
    fi
    tmux split-window -h "docker logs -t ${var} -f"
    NUM=$((NUM+1))
done
LOCAL=$(docker ps --format '{{.Names}}' --filter 'name=_bc' | grep local)
tmux select-window -t ${LOCAL}
tmux select-pane -t 0
tmux attach-session -t $(basename `git rev-parse --show-toplevel`)
