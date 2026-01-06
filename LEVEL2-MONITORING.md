# Level 2 Monitoring & Observability Setup

## Overview
This level implements comprehensive monitoring and observability for the Fusionpact DevOps Challenge application using Prometheus and Grafana.

## Monitoring Stack Components

### 1. Prometheus (Port 9090)
- **Purpose**: Metrics collection and storage ee
- **Configuration**: `prometheus.yml`
- **Targets**: 
  - Backend API metrics (`/metrics` endpoint)
  - Container metrics via cAdvisor
  - System metrics via Node Exporter
  - Self-monitoring

### 2. Grafana (Port 3000)
- **Purpose**: Metrics visualization and dashboards
- **Credentials**: admin / admin123
- **Datasource**: Prometheus (auto-configured)
- **Dashboard**: Pre-configured infrastructure and application metrics

### 3. cAdvisor (Port 8081)
- **Purpose**: Container resource usage monitoring
- **Metrics**: CPU, Memory, Network, Disk usage per container
- **Integration**: Scraped by Prometheus

### 4. Node Exporter (Port 9100)
- **Purpose**: Host system metrics
- **Metrics**: CPU, Memory, Disk, Network for the host system
- **Integration**: Scraped by Prometheus

## Key Metrics Monitored

### Infrastructure Metrics
- **Container CPU Usage**: `rate(container_cpu_usage_seconds_total[5m]) * 100`
- **Container Memory Usage**: `container_memory_usage_bytes`
- **System Load**: `node_load1`, `node_load5`, `node_load15`
- **Disk Usage**: `node_filesystem_avail_bytes`
- **Network I/O**: `rate(container_network_receive_bytes_total[5m])`

### Application Metrics
- **HTTP Request Rate**: `rate(http_requests_total[5m])`
- **HTTP Request Latency**: `histogram_quantile(0.95, rate(http_request_duration_seconds_bucket[5m]))`
- **Error Rate**: `rate(http_requests_total{status=~"5.."}[5m])`
- **Active Connections**: `http_requests_currently_in_flight`

## Dashboard Features

### Infrastructure Dashboard
- Real-time container CPU and memory usage
- System resource utilization
- Network and disk I/O metrics
- Container health status

### Application Dashboard
- API request rate and latency
- Error rate monitoring
- Response time percentiles
- Endpoint-specific metrics

## Access URLs
- **Frontend**: http://localhost:8080
- **Backend API**: http://localhost:8000
- **Prometheus**: http://localhost:9090
- **Grafana**: http://localhost:3000 (admin/admin123)
- **cAdvisor**: http://localhost:8081
- **Node Exporter**: http://localhost:9100

## File Structure
```
├── prometheus.yml                          # Prometheus configuration
├── grafana/
│   └── provisioning/
│       ├── datasources/
│       │   └── prometheus.yml             # Grafana datasource config
│       └── dashboards/
│           ├── dashboard.yml              # Dashboard provider config
│           └── fusionpact-dashboard.json  # Pre-built dashboard
├── docker-compose.monitoring.yml          # Complete monitoring stack
└── health-check-level2.ps1               # Health check script
```

## Usage Instructions

### Start Monitoring Stack
```bash
docker-compose -f docker-compose.monitoring.yml up -d
```

### Check Status
```bash
docker-compose -f docker-compose.monitoring.yml ps
```

### Run Health Check
```bash
.\health-check-level2.ps1
```

### Access Grafana
1. Open http://localhost:3000
2. Login with admin/admin123
3. Navigate to pre-configured dashboard
4. Monitor real-time metrics

### Query Prometheus
1. Open http://localhost:9090
2. Use PromQL queries to explore metrics
3. Example queries:
   - `up` - Service availability
   - `rate(http_requests_total[5m])` - Request rate
   - `container_memory_usage_bytes` - Memory usage

## Key Monitoring Scenarios

### 1. Service Health Monitoring
- All services report "up" status in Prometheus targets
- Health checks pass for all endpoints
- Container health status visible in cAdvisor

### 2. Performance Monitoring
- Request latency tracked via histogram metrics
- CPU and memory usage monitored per container
- Resource utilization alerts possible

### 3. Error Monitoring
- HTTP error rates tracked by status code
- Failed health checks visible in Prometheus
- Container restart events monitored

## Level 2 Requirements Completed ✅

1. **✅ Prometheus Setup**: Configured to scrape backend `/metrics`
2. **✅ Infrastructure Metrics**: CPU, memory, disk, container usage via cAdvisor + Node Exporter
3. **✅ Application Metrics**: Request rate, latency, error counts from FastAPI
4. **✅ Grafana Dashboards**: Real-time visualization of all metrics
5. **✅ Real-time Data**: All dashboards show live metrics from deployed services

## Next Steps
Ready for Level 3 - CI/CD Automation with Jenkins or GitHub Actions! 🚀
