tmux kill-server > /dev/null 2>&1
docker-compose up -d
array=$(docker ps --format '{{.Names}}' --filter 'name=_fe')
NUM=0
for var in ${array[@]}
do
    if [ $NUM = 0 ]; then
        tmux new-session -s multicloud_python_batch  -n ${var} -d "docker exec -it ${var} /bin/sh";
    else
        tmux new-window  -t multicloud_python_batch:${NUM} -n ${var}  "docker exec -it ${var} /bin/sh";
    fi
    tmux split-window -h "docker logs -t ${var} -f"
    NUM=$((NUM+1))
done
LOCAL=$(docker ps --format '{{.Names}}' --filter 'name=_fe' | grep local)
tmux select-window -t ${LOCAL}
tmux select-pane -t 0
tmux attach-session -t multicloud_python_batch
