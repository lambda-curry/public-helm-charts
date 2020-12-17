{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "ghost.name" }}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this
(by the DNS naming spec).
*/}}
{{- define "ghost.fullname" }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Calculate ghost certificate
*/}}
{{- define "ghost.ghost-certificate" }}
{{- if (not (empty .Values.ingress.ghost.certificate)) }}
{{- printf .Values.ingress.ghost.certificate }}
{{- else }}
{{- printf "%s-ghost-letsencrypt" (include "ghost.fullname" .) }}
{{- end }}
{{- end }}

{{/*
Calculate ghost hostname
*/}}
{{- define "ghost.ghost-hostname" }}
{{- if (and .Values.config.ghost.hostname (not (empty .Values.config.ghost.hostname))) }}
{{- printf .Values.config.ghost.hostname }}
{{- else }}
{{- if .Values.ingress.ghost.enabled }}
{{- printf .Values.ingress.ghost.hostname }}
{{- else }}
{{- printf "%s-ghost" (include "ghost.fullname" .) }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Calculate ghost base url
*/}}
{{- define "ghost.ghost-base-url" }}
{{- $hostname := .Values.ingress.ghost.hostname }}
{{- printf "https://" .Values.ingress.ghost.hostname }}
{{- end }}
