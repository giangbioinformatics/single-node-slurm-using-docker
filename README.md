# Single-node-slurm-using-docker
POC for how to set up the basic SLURM cluster using single node

## Requirements
+ Docker installization or you can use your own debian-based OS computing resource
+ SSH-client

## Create docker image
+ Build
```bash
docker build slurm -t river-slurm:0.0.1-rc
```
+ Run
```bash
docker run --rm -p 8081:22 --name slurm -d river-slurm:0.0.1-rc
```

+ Login to this slurm docker image
```bash
ssh river@localhost -p 8081 
```


## Test slurm job
After login, you can submit job, due to only a single node, it can not allocate a part resource of target workers and redirect you to this resource.
It is just a part of your login node. Overall, your controller, your worker and login nodes are configured on a single node.
```bash
srun --pty bash
```