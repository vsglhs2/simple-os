export $(grep -v '^#' .env | xargs)

docker build --tag $IMAGE_NAME --platform linux/amd64 .
CONTAINER=$(docker create --platform linux/amd64 $IMAGE_NAME)
docker cp $CONTAINER:/build .
docker rm $CONTAINER