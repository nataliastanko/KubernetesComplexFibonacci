docker build -t nataliastanko/multi-client-fib:latest -t nataliastanko/multi-client-fib:$SHA -f ./client/Dockerfile ./client
docker build -t nataliastanko/multi-serverfib:latest -t nataliastanko/multi-server-fib:$SHA -f ./server/Dockerfile ./server
docker build -t nataliastanko/multi-workerfib:latest -t nataliastanko/multi-worker-fib:$SHA -f ./worker/Dockerfile ./worker

docker push nataliastanko/multi-client-fib:latest
docker push nataliastanko/multi-server-fib:latest
docker push nataliastanko/multi-worker-fib:latest

docker push nataliastanko/multi-client-fib:$SHA
docker push nataliastanko/multi-server-fib:$SHA
docker push nataliastanko/multi-worker-fib:$SHA

kubectl apply -f k8s
kubectl set image deployments/server-deployment server=nataliastanko/multi-server-fib:$SHA
kubectl set image deployments/client-deployment client=nataliastanko/multi-client-fib:$SHA
kubectl set image deployments/worker-deployment worker=nataliastanko/multi-worker-fib:$SHA