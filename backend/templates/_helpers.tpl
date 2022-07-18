{{/*
Expand the name of the chart.
*/}}
{{- define "backend.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "backend.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "backend.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "backend.labels" -}}
helm.sh/chart: {{ include "backend.chart" . }}
{{ include "backend.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "backend.selectorLabels" -}}
app.kubernetes.io/name: {{ include "backend.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "backend.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "backend.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{- define "backend.env" -}}
{{- with . -}}
{{- range $key, $val := . }} 
- name: {{ $key }}
  {{- if hasPrefix "\"secret:" ($val | quote) }}
  valueFrom:   
    secretKeyRef:
      name: {{$val | trimPrefix "secret:" | splitList "." | first }}
      key: {{ $val | splitList "." | rest | join "." }}
  {{- else if hasPrefix "\"configmap:" ($val | quote) }}
  valueFrom:   
    configMapKeyRef:
      name: {{ $val | trimPrefix "configmap:" | splitList "." | first }}
      key: {{ $val | splitList "." | rest | join "." }}
  {{- else }}
  value: {{ $val | quote }}
  {{- end }}
{{- end }}
{{- end }}
{{- end -}}


{{- define "backend.extraEnv" -}}
{{- with . -}}
{{ . | toYaml }}
{{- end }}
{{- end -}}


{{- define "backend.cmd" -}}
{{- with .command }}
command: {{ . | toYaml | nindent 2 }}
{{- end }}
{{- with .args }}
args: {{ . | toYaml | nindent 2 }}
{{- end }}
{{- end -}}


{{- define "backend.resources" -}}
{{- with . }}
resources: {{ . | toYaml | nindent 2 }}
{{- end }}
{{- end -}}