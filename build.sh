export $(grep -v '^#' .env | xargs)

rm -rf ./build
docker build --platform linux/amd64 --tag $IMAGE_NAME --build-arg IMAGE_NAME=$IMAGE_NAME .
CONTAINER=$(docker create --platform linux/amd64 $IMAGE_NAME)
docker cp $CONTAINER:/build .
docker rm $CONTAINER