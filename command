command
Within the Explorer view right-click over the lab/code/App/lab-code/flaskapp folder and then select the Open in Terminal menu option:

A new terminal session is presented in the bottom pane. List the contents of the flaskapp directory. In the terminal execute the following command:


ls -la

Perform a docker build to create a custom docker image. In the terminal execute the following command:


docker build -t cloudacademydevops/flaskapp 

Check to see the presence of the newly built docker image with the tag cloudacademydevops/flaskapp:latest. In the terminal execute the following command:


docker images 

Create a custom cloudacademy namespace within the Kubernetes cluster. In the terminal execute the following command:

kubectl create ns cloudacademy
Swap into the new cloudacademy namespace. In the terminal execute the following command:


kubectl config set-context --current --namespace=cloudacademy

Change into the k8s directory and list out its contents. In the terminal execute the following command:


cd ../k8s && ls -la 
Within the Explorer view, navigate to and open the lab/code/App/lab-code/k8s/nginx.configmap.yaml manifest file.

 review and understand the design and intent of the nginx.configmap.yaml manifest file - which will be used to create a new ConfigMap cluster resource:



kubectl apply -f nginx.configmap.yaml

List out all of the ConfigMap resourses in the K8s cluster. In the terminal execute the following command:


kubectl get configmaps

. Within the Explorer view, navigate to and open the lab/code/App/lab-code/k8s/deployment.yaml manifest file.

Take sometime to review and understand the design and intent of the deployment.yaml manifest file:

 Apply the updated deployment.yaml file into the K8s cluster - this will create a new Deployment resource. In the terminal execute the following command:


kubectl apply -f deployment.yaml

List out all of the deployments in the K8s cluster. In the terminal execute the following command:


kubectl get deploy 
List out all of the pods in the K8s cluster. In the terminal execute the following command:


kubectl get pods

Notice how the frontend pod has 1/2 containers in a READY state, and that there is an ErrImagePull issue. Let's now troubleshoot and fix this.

8. Extract the frontend pod name and store it in a variable named POD_NAME. Echo it back out to the terminal. In the terminal execute the following commands:


POD_NAME=`kubectl get pods -o jsonpath='{.items[0].metadata.name}'`
echo $POD_NAME

Now use the kubectl describe command to get a detailed report on the current status of the frontend pod. In the terminal execute the following command:

kubectl describe pod $POD_NAME

Use the docker images command to confirm the correct docker image tag for the FLASK based web application that you built in Lab Step 1. In the terminal execute the following command:

docker images | grep cloudacademydevops
Here you can see that indeed the correct image tag is cloudacademydevops/flaskapp.

Now use the sed command to perform an inline find for the incorrect image tag cloudacademydevops/flask and replace it with the correct image tag cloudacademydevops/flaskapp within the deployment.yaml file. In the terminal execute the following command:

sed -i 's/cloudacademydevops\/flask/cloudacademydevops\/flaskapp/g' deployment.yaml

 Within the Editor view, confirm that the updated file deployment.yaml manifest file is now using the correct container image tag for the FLASK container (line 35):

Apply the updated deployment.yaml file back into the K8s cluster - this will update the existing Deployment resource. In the terminal execute the following command:

kubectl apply -f deployment.yaml

List out all of the Deployment resourses in the K8s cluster. In the terminal execute the following command:

kubectl get deploy

Notice how the frontend deployment is now showing 1/1 replicas READY. This confirms that we have corrected and fixed the previous mistake

Expose the frontend deployment. This will create a new Service resource which will allow the frontend pods to be called via a stable cluster network VIP address . In the terminal execute the following command:

kubectl expose deployment frontend --port=80 --target-port=80

List out the new frontend Service resource previously created. In the terminal execute the following command:


kubectl get svc frontend 

Extract the frontend service cluster IP address and store it in a variable named FRONTEND_SERVICE_IP. Echo it back out to the terminal. In the terminal execute the following commands:


FRONTEND_SERVICE_IP=`kubectl get service/frontend -o jsonpath='{.spec.clusterIP}'`
echo $FRONTEND_SERVICE_IP

Test the frontend service by sending a curl request to it. In the terminal execute the following command:


curl -i http://$FRONTEND_SERVICE_IP
Edit and update the deployment.yaml manifest file by updating the APP_NAME environment variable to be "CloudAcademy.DevOps.K8s.Manifest.v2.00", like so:

Apply the updated deployment.yaml file back into the K8s cluster - this will update the existing frontend Deployment resource. In the terminal execute the following command:


kubectl apply -f deployment.yaml

Retest the frontend service by sending a new curl request to it. In the terminal execute the following command:


curl -i http://$FRONTEND_SERVICE_IP

let's now examine the logs associated with sending traffic through the NGINX web server. For starters list out the current pods within the cluster. In the terminal execute the following command:

kubectl get pods

 Extract the frontend pod name and store it in a variable named FRONTEND_POD_NAME. Echo it back out to the terminal. In the terminal execute the following commands:

FRONTEND_POD_NAME=`kubectl get pods --no-headers -o custom-columns=":metadata.name"`
echo $FRONTEND_POD_NAME

Perform a directory listing directly within the NGINX container listing out the contents of the /var/log/nginx directory. In the terminal execute the following command:

kubectl exec -it $FRONTEND_POD_NAME -c nginx -- ls -la /var/log/nginx/

Use the kubectl logs command to examine the NGINX logging generated by the previously executed curl commands . In the terminal execute the following command:


kubectl logs $FRONTEND_POD_NAME nginx
Use the kubectl logs command to examine the FLASK logging generated by the previously executed curl commands. In the terminal execute the following command:


kubectl logs $FRONTEND_POD_NAME flask
For starters navigate up one directory into the lab/code/App/lab-code/ directory. In the terminal execute the following command:


cd ..

Use the helm create command to generate a new Helm Chart project named test-app. In the terminal execute the following command:


helm create test-app

Use the tree command to render out the directory structure to the screen. In the terminal execute the following command:

tree test-app/

Use the helm template command to convert the Helm templates into a single deployable Kubernetes manifest file. In the terminal execute the following command:


helm template test-ap

Begin by removing all previous resources launched within the cluster. Use the kubectl delete command to delete the Deployment, Pod, and Service resources created earlier. In the terminal execute the following command:


kubectl delete deploy,pods,svc --all

Within the Explorer view, navigate to and open the Helm lab/code/App/lab-code/app/values.yaml file.

Within the values.yaml file locate and edit the #Code3.0 comment block, adding the following configuration:


#CODE3.0:
#create new configuration value which will store a message to be passed into the Flask web app as an environment variable
webapp:
  message: CloudAcademy.DevOps.K8s.Helm
This is used to declare the variable webapp.message which holds the string "CloudAcademy.DevOps.K8s.Helm". The variable webapp.message is referenced within the templates/deployment.yaml file which you will edit and update next.

Within the Explorer view, navigate to and open the Helm lab/code/App/lab-code/app/templates/deployment.yaml file. 

Within the deployment.yaml file locate and edit the #Code3.1 comment block, adding the following configuration:


#CODE3.1:
#create the APP_NAME environment variable and configure to use the Helm value {{ .Values.webapp.message }}
- name: APP_NAME
  value: {{ .Values.webapp.message }}
This is used to reference the variable webapp.message which holds the string "CloudAcademy.DevOps.K8s.Helm".
 Use the helm template command to generate a deployable manifest file. In the terminal execute the following command:

helm template ./app
This time  will perform the actual deployment into the cluster. To do so will again use the helm template command to generate a deployable manifest file, piping the output (manifest) directly into the kubectl apply command. In the terminal execute the following command:

helm template cloudacademy ./app | kubectl apply -f -

Examine the current services available within the cluster . In the terminal execute the following command:


kubectl get svc

Extract the cloudacademy-app service cluster IP address and store it in a variable named CLOUDACADEMY_APP_IP. Echo it back out to the terminal. In the terminal execute the following commands:

CLOUDACADEMY_APP_IP=`kubectl get service/cloudacademy-app -o jsonpath='{.spec.clusterIP}'`
echo $CLOUDACADEMY_APP_IP

Test the cloudacademy-app service by sending a curl request to it. In the terminal execute the following command:


curl -i http://$CLOUDACADEMY_APP_IP

Moving on. Create both dev and prod specific copies of the app/values.yaml file. In the terminal execute the following command:


cp app/values.yaml app/values.dev.yaml
cp app/values.yaml app/values.prod.yaml

Perform a dev redeployment back into the cluster by referencing the values.dev.yaml Values file within the helm template command. In the terminal execute the following command:


helm template cloudacademy -f ./app/values.dev.yaml ./app | kubectl apply -f -

Retest the cloudacademy-app service by sending another curl request to it. In the terminal execute the following command:


curl -i http://$CLOUDACADEMY_APP_IP

Perform a prod redeployment back into the cluster by referencing the values.prod.yaml Values file within the helm template command. In the terminal execute the following command:


helm template cloudacademy -f ./app/values.prod.yaml ./app | kubectl apply -f -

 Retest the cloudacademy-app service by sending another curl request to it. In the terminal execute the following command:

curl -i http://$CLOUDACADEMY_APP_IP

Use the helm command to package up the app into a chart. In the terminal execute the following command:


helm package app/

Perform a directory listing to confirm that the chart was successfully created. In the terminal execute the following command:


ls -la

Before installing the new chart, reverse out (delete) all of the previous helm deployed resources. In the terminal execute the following command:

helm template cloudacademy -f ./app/values.prod.yaml ./app | kubectl delete -f - 

Install the new chart. In the terminal execute the following command:

helm install cloudacademy-app app-0.1.0.tgz

List out all of the current Helm releases for the current namespace context. In the terminal execute the following command:

helm ls 

Display the deployment, pod, and service resources that were created due to the helm chart installation. In the terminal execute the following command:


kubectl get deploy,pods,svc

 Extract the cloudacademy-app service cluster IP address and store it in a variable named CLOUDACADEMY_APP_IP. Echo it back out to the terminal. In the terminal execute the following commands:


CLOUDACADEMY_APP_IP=`kubectl get service/cloudacademy-app -o jsonpath='{.spec.clusterIP}'`
echo $CLOUDACADEMY_APP_IP

 Test the cloudacademy-app service by sending a curl request to it. In the terminal execute the following command:


curl -i http://$CLOUDACADEMY_APP_IP

