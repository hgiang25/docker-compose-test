# Thêm repo cho Loki (Community mới) và Promtail
helm repo add grafana-community https://grafana-community.github.io/helm-charts
helm repo add grafana https://grafana.github.io/helm-charts

# Cập nhật lại danh sách chart
helm repo update

# install loki
helm upgrade --install loki grafana-community/loki --namespace loki --create-namespace -f values-loki.yaml

#appli nodeport
kubectl apply -f loki-gateway-nodeport.yaml -n loki
