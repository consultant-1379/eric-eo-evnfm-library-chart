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

{{/* vim: set filetype=mustache: */}}

{{/*
Define DB connection pool max life time property
If not set by user, defaults to 14 minutes.
*/}}
{{ define "eric-eo-evnfm-library-chart.db.connection.pool.max.lifetime" -}}
- name: "spring.datasource.hikari.max-lifetime"
  value: {{ index .Values "global" "db" "connection" "max-lifetime" | default "840000" | quote -}}
{{- end -}}
