#
# COPYRIGHT Ericsson 2023
#
#
#
# The copyright to the computer program(s) herein is the property of
#
# Ericsson Inc. The programs may be used and/or copied only with written
#
# permission from Ericsson Inc. or in accordance with the terms and
#
# conditions stipulated in the agreement/contract under which the
#
# program(s) have been supplied.
#

{{/*
  GL-D470217-080-AD
  This helper captures the service mesh version from the integration chart to
  annotate the workloads so they are redeployed in case of service mesh upgrade.
*/}}
{{- define "eric-eo-evnfm-library-chart.service-mesh-version" }}
  {{- if eq (include "eric-eo-evnfm-library-chart.service-mesh-enabled" .) "true" }}
    {{- if .Values.global.serviceMesh -}}
      {{- if .Values.global.serviceMesh.annotations -}}
        {{ .Values.global.serviceMesh.annotations | toYaml }}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}


{{/*
  DR-D470217-007-AD This helper defines whether this service enter the Service Mesh or not.
*/}}
{{- define "eric-eo-evnfm-library-chart.service-mesh-enabled" }}
  {{- $globalMeshEnabled := "false" -}}
  {{- if .Values.global -}}
    {{- if .Values.global.serviceMesh -}}
      {{- $globalMeshEnabled = .Values.global.serviceMesh.enabled -}}
    {{- end -}}
  {{- end -}}
  {{- $globalMeshEnabled -}}
{{- end -}}

{{/*
  DR-D470217-011 This helper defines the annotation which bring the service into the mesh.
*/}}
{{- define "eric-eo-evnfm-library-chart.service-mesh-inject" }}
  {{- if eq (include "eric-eo-evnfm-library-chart.service-mesh-enabled" .) "true" }}
sidecar.istio.io/inject: "true"
  {{- else -}}
sidecar.istio.io/inject: "false"
  {{- end -}}
{{- end -}}

{{/*
  DR-D470217-011 This helper defines the annotation to jobs with disabled istio proxy.
*/}}
{{- define "eric-eo-evnfm-library-chart.service-mesh-inject-job" }}
sidecar.istio.io/inject: "false"
{{- end -}}

{{/*
  Definition of log level for Service Mesh.
*/}}
{{- define "eric-eo-evnfm-library-chart.service-mesh-logs" }}
  {{- if .Values.highAvailability.debug }}
sidecar.istio.io/logLevel: debug
  {{- else -}}
sidecar.istio.io/logLevel: info
  {{- end -}}
{{- end -}}

{{/*
  Istio excludeOutboundPorts. Outbound ports to be excluded from redirection to Envoy.
*/}}
{{- define "eric-eo-evnfm-library-chart.excludeOutboundPorts" -}}
  {{- if eq (include "eric-eo-evnfm-library-chart.service-mesh-enabled" .) "true" -}}
    {{- if .Values.istio -}}
      {{- if .Values.istio.excludeOutboundPorts -}}
traffic.sidecar.istio.io/excludeOutboundPorts: {{ .Values.istio.excludeOutboundPorts }}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
  Istio excludeInboundPorts. Inbound ports to be excluded from redirection to Envoy.
*/}}
{{- define "eric-eo-evnfm-library-chart.excludeInboundPorts" -}}
  {{- if eq (include "eric-eo-evnfm-library-chart.service-mesh-enabled" .) "true" -}}
    {{- if .Values.istio -}}
      {{- if .Values.istio.excludeInboundPorts -}}
traffic.sidecar.istio.io/excludeInboundPorts: {{ .Values.istio.excludeInboundPorts }}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}
