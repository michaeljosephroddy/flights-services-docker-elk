## Flightservice Deployment

Microservices architecture is a software development approach where an application is broken down into small, independent services. Each service is responsible for a specific business function and can be developed, deployed, and scaled independently. This approach offers several benefits, including improved scalability, maintainability, and resilience.
Containerization, through technologies like Docker, provides a lightweight and portable way to package and run applications and their dependencies. Containers isolate applications from the underlying host system, ensuring consistent behavior across different environments.
Container orchestration tools play a crucial role in managing and scaling microservices deployed in containerized environments. These tools automate tasks such as deployment, scaling, load balancing, and service discovery, making it easier to manage and maintain complex microservices architectures.

### Docker Compose Deployment

Docker Compose is a tool for defining and running multi-container Docker applications. It uses a YAML file to define the services that make up an application, their dependencies, and their configuration.

To demonstrate docker compose we will deploy docker containers using a `docker-compose.yml` file.
I have defined the java microservice, mysql and the ELK stack in the `docker-compose.yml`.

There are some dependencies for this docker-compose.yml file like:

`init.sql`
`logstash.conf`
`flightservices.jar file.`

To start up the containers with docker-compose run: `sudo docker-compose up –build`.
This will launch the containers locally.
Once the containers are up and running we can start calling the `/flights` endpoint.

I set the java microservice to log to `logs/application.log` file using SLF4J.
After calling the `/flights` endpoint with `curl  http://localhost:8080/flights/`, the java code will put an entry in the log file.

Logstash will collect the log file entries and send them over to elasticsearch for indexing and we can monitor the logs in Kibana at `http://localhost:5601`.

### Docker Swarm

Docker Swarm is a native clustering solution for Docker that turns a pool of Docker hosts into a single, virtual Docker host. It provides a simple way to manage and scale Docker applications across a cluster of machines.

To demonstrate docker swarm, we will set up 3 EC2 instances and deploy the `docker-compose.yml` file from the previous section.
I used Terraform to set up EC2 instead of manually configuring each instance in the console.
Take a look at `tform/main.tf`.

Prepare the wokring directory: `terraform init`
Run: `terraform plan`
followed by: `terraform apply`.

From here we can set up docker swarm by sshing into the manager node and running `docker swarm init`, then taking the join key and sshing into the worker nodes and joining the worker nodes to the swarm by using the join key.

The command is, `docker swarm join --token <WORKER_TOKEN> <MANAGER_IP>:2377`.

Then we can run, `docker stack deploy` on the manager node, using the `docker-compose.yml`.

To scale the services you can run: `docker service scale <stack_name>_<service_name>=<number_of_replicas>`.
If you want to update a service to a more recent version, you can run: `docker service update –image <image_name> <stack_name>`.
If for instance something goes wrong after updating you can rollback to the previous version using: `docker service rollback <image_name>`.

Docker Swarm offers several advantages for microservices deployment:

1. Simplified scaling: Easily scale services across a cluster of machines.
2. High availability: Ensure high availability of services by distributing them across multiple nodes.
3. Native integration with Docker: Seamlessly integrates with the Docker ecosystem.
