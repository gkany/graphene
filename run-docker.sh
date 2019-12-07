version=$1
name=$2
tag="graphene:v"${version}

docker build -t  ${tag}  .
docker run --name  ${name} -dit  -p 8049:8049 -p 8050:8050 ${tag}

