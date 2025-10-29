date=$(date '+%Y-%m-%d')

docker build --platform=linux/amd64 --pull --rm -f "container_files/DOCKERFILE" -t hemprichbennett/qpcr_ag_img:$date "."

docker push hemprichbennett/qpcr_ag_img:$date
