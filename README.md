# Kubernetes Troubleshooting Lab Helm Chart

A small Helm chart designed for Killercoda or any disposable Kubernetes cluster. It deploys healthy workloads alongside deliberately broken workloads.

## Workloads

| Workload | Expected state | Scenario |
|---|---|---|
| NGINX | Running | Healthy web service |
| Redis | Running | Healthy cache service |
| crashloop-app | CrashLoopBackOff | Container exits with code 1 after reporting a missing configuration file |
| oom-app | CrashLoopBackOff | Python allocates more memory than its 32 MiB limit and is OOMKilled |
| MongoDB | Pending | Pod references a PVC that intentionally does not exist |

## Install in Killercoda

```bash
kubectl create namespace troubleshooting-lab
helm install lab ./k8s-troubleshooting-lab -n troubleshooting-lab
kubectl get pods -n troubleshooting-lab -w
```

Or install the packaged chart:

```bash
helm install lab ./k8s-troubleshooting-lab-0.1.0.tgz \
  --namespace troubleshooting-lab \
  --create-namespace
```

## Investigation commands

```bash
kubectl get pods -n troubleshooting-lab
kubectl get events -n troubleshooting-lab --sort-by=.lastTimestamp
kubectl describe pod -n troubleshooting-lab <pod-name>
kubectl logs -n troubleshooting-lab <pod-name>
kubectl logs -n troubleshooting-lab <pod-name> --previous
```

Check the OOMKilled reason:

```bash
OOM_POD=$(kubectl get pod -n troubleshooting-lab -l app.kubernetes.io/name=oom-app -o jsonpath='{.items[0].metadata.name}')
kubectl get pod -n troubleshooting-lab "$OOM_POD" \
  -o jsonpath='{.status.containerStatuses[0].lastState.terminated.reason}{"\n"}'
```

## Fix exercises

### CrashLoopBackOff

The deployment command deliberately exits with code 1. Inspect the deployment and replace its command with a long-running process, for example:

```bash
kubectl edit deployment -n troubleshooting-lab lab-k8s-troubleshooting-lab-crashloop
```

Use:

```yaml
command: ["sh", "-c"]
args: ["echo application started; sleep 3600"]
```

### OOMKilled

Increase the memory limit or reduce `outOfMemory.allocationMiB`:

```bash
helm upgrade lab ./k8s-troubleshooting-lab -n troubleshooting-lab \
  --set outOfMemory.memoryLimit=256Mi
```

### Missing PVC

```bash
kubectl apply -n troubleshooting-lab -f - <<'YAML'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: mongodb-data-missing
spec:
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 1Gi
YAML
```

## Remove

```bash
helm uninstall lab -n troubleshooting-lab
kubectl delete namespace troubleshooting-lab
```
