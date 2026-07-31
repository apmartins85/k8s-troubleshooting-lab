{{- define "k8s-troubleshooting-lab.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "k8s-troubleshooting-lab.fullname" -}}
{{- printf "%s-%s" .Release.Name (include "k8s-troubleshooting-lab.name" .) | trunc 63 | trimSuffix "-" }}
{{- end }}

{{- define "k8s-troubleshooting-lab.namespace" -}}
{{- default .Release.Namespace .Values.namespaceOverride }}
{{- end }}

{{- define "k8s-troubleshooting-lab.labels" -}}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: troubleshooting-lab
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version | quote }}
{{- end }}
