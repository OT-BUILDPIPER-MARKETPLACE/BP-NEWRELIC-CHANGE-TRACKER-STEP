apiVersion: v1
kind: ConfigMap
metadata:
  name: prometheus-config
  namespace: monitoring
data:
  prometheus.yml: |
    global:
      scrape_interval:     15s
      evaluation_interval: 15s
    alerting:
      alertmanagers:
      - static_configs:
        - targets:
    rule_files:
      # - "example-file.yml"
    scrape_configs:
        - job_name: 'prometheus'
            static_configs:
            - targets: ['localhost:9090']
        - job_name: 'kubelet'
        kubernetes_sd_configs:
        - role: node
        scheme: https
        tls_config:
            ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
            insecure_skip_verify: true  
        - job_name: 'cadvisor'
            kubernetes_sd_configs:
            - role: node
            scheme: https
            tls_config:
                ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
                insecure_skip_verify: true  # Required with Minikube.
            metrics_path: /metrics/cadvisor
        - job_name: 'k8apiserver'
            kubernetes_sd_configs:
            - role: endpoints
            scheme: https
            tls_config:
                ca_file: /var/run/secrets/kubernetes.io/serviceaccount/ca.crt
                insecure_skip_verify: true  # Required if using Minikube.
            bearer_token_file: /var/run/secrets/kubernetes.io/serviceaccount/token
            relabel_configs:
        - source_labels: [__meta_kubernetes_namespace, __meta_kubernetes_service_name, __meta_kubernetes_endpoint_port_name]
                action: keep
                regex: default;kubernetes;https
        - job_name: 'k8services'
            kubernetes_sd_configs:
            - role: endpoints
            relabel_configs:
            - source_labels:
                - __meta_kubernetes_namespace
                - __meta_kubernetes_service_name
                action: drop
                regex: default;kubernetes
            - source_labels:
                - __meta_kubernetes_namespace
                regex: default
                action: keep
            - source_labels: [__meta_kubernetes_service_name]
                target_label: job
        - job_name: 'k8pods'
            kubernetes_sd_configs:
            - role: pod
            relabel_configs:
            - source_labels: [__meta_kubernetes_pod_container_port_name]
                regex: metrics
                action: keep
            - source_labels: [__meta_kubernetes_pod_container_name]
                target_label: job