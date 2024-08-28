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
Create main image registry url
*/}}
{{- define "eric-eo-evnfm-library-chart.mainImagePath" -}}
    {{- $ctx := .ctx -}}
    {{- $svcRegistryName := .svcRegistryName -}}
    {{- $productInfo := fromYaml ($ctx.Files.Get "eric-product-info.yaml") -}}
    {{- $registryUrl := index $productInfo "images" $svcRegistryName "registry" -}}
    {{- $repoPath := index $productInfo "images" $svcRegistryName "repoPath" -}}
    {{- $name := index $productInfo "images" $svcRegistryName "name" -}}
    {{- $tag := index $productInfo "images" $svcRegistryName "tag" -}}
    {{- if $ctx.Values.global -}}
        {{- if $ctx.Values.global.registry -}}
            {{- if $ctx.Values.global.registry.url -}}
                {{- $registryUrl = $ctx.Values.global.registry.url -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- if $ctx.Values.imageCredentials -}}
        {{- if index $ctx "Values" "imageCredentials" $svcRegistryName -}}
            {{- if index $ctx "Values" "imageCredentials" $svcRegistryName "registry" -}}
                {{- if index $ctx "Values" "imageCredentials" $svcRegistryName "registry" "url" -}}
                    {{- $registryUrl = index $ctx "Values" "imageCredentials" $svcRegistryName "registry" "url" -}}
                {{- end -}}
            {{- end -}}
            {{- if not (kindIs "invalid" (index $ctx "Values" "imageCredentials" $svcRegistryName "repoPath")) -}}
                {{- $repoPath = index $ctx "Values" "imageCredentials" $svcRegistryName "repoPath" -}}
            {{- else if not (kindIs "invalid" (index $ctx "Values" "global" "registry" "repoPath")) }}
                {{- $repoPath = index $ctx "Values" "global" "registry" "repoPath" -}}
            {{- end -}}
            {{- if not (kindIs "invalid" (index $ctx "Values" "imageCredentials" $svcRegistryName "name")) -}}
                {{- $name = index $ctx "Values" "imageCredentials" $svcRegistryName "name" -}}
            {{- end -}}
            {{- if not (kindIs "invalid" (index $ctx "Values" "imageCredentials" $svcRegistryName "tag")) -}}
                {{- $tag = index $ctx "Values" "imageCredentials" $svcRegistryName "tag" -}}
            {{- end -}}
        {{- end -}}
        {{- if not (kindIs "invalid" $ctx.Values.imageCredentials.repoPath) -}}
            {{- $repoPath = $ctx.Values.imageCredentials.repoPath -}}
        {{- end -}}
    {{- end -}}
    {{- if $repoPath -}}
        {{- $repoPath = printf "%s/" $repoPath -}}
    {{- end -}}
    {{- printf "%s/%s%s:%s" $registryUrl $repoPath $name $tag -}}
{{- end -}}

{{/*
The pgInitContainer image registry url
*/}}
{{- define "eric-eo-evnfm-library-chart.pgInitContainerPath" -}}
    {{- $productInfo := fromYaml (.Files.Get "eric-product-info.yaml") -}}
    {{- $registryUrl := $productInfo.images.pgInitContainer.registry -}}
    {{- $repoPath := $productInfo.images.pgInitContainer.repoPath -}}
    {{- $name := $productInfo.images.pgInitContainer.name -}}
    {{- $tag := $productInfo.images.pgInitContainer.tag -}}
    {{- if .Values.global -}}
        {{- if .Values.global.registry -}}
            {{- if .Values.global.registry.url -}}
                {{- $registryUrl = .Values.global.registry.url -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- if .Values.imageCredentials -}}
        {{- if .Values.imageCredentials.pgInitContainer -}}
            {{- if .Values.imageCredentials.pgInitContainer.registry -}}
                {{- if .Values.imageCredentials.pgInitContainer.registry.url -}}
                    {{- $registryUrl = .Values.imageCredentials.pgInitContainer.registry.url -}}
                {{- end -}}
            {{- end -}}
            {{- if not (kindIs "invalid" .Values.imageCredentials.pgInitContainer.repoPath) -}}
                {{- $repoPath = .Values.imageCredentials.pgInitContainer.repoPath -}}
            {{- end -}}
        {{- end -}}
        {{- if not (kindIs "invalid" .Values.imageCredentials.repoPath) -}}
            {{- $repoPath = .Values.imageCredentials.repoPath -}}
        {{- end -}}
    {{- end -}}
    {{- if $repoPath -}}
        {{- $repoPath = printf "%s/" $repoPath -}}
    {{- end -}}
    {{- printf "%s/%s%s:%s" $registryUrl $repoPath $name $tag -}}
{{- end -}}

{{/*
Create image pull secrets
*/}}
{{- define "eric-eo-evnfm-library-chart.pullSecrets" -}}
    {{- if .Values.imageCredentials.pullSecret -}}
        {{- print .Values.imageCredentials.pullSecret -}}
    {{- else if .Values.global.pullSecret -}}
        {{- print .Values.global.pullSecret -}}
    {{- else if .Values.imageCredentials.registry -}}
        {{- if .Values.imageCredentials.registry.pullSecret -}}
            {{- print .Values.imageCredentials.registry.pullSecret -}}
        {{- end -}}
    {{- else if .Values.global.registry.pullSecret -}}
        {{- print .Values.global.registry.pullSecret -}}
    {{- end -}}
{{- end -}}

{{/*
Create Ericsson Product Info
*/}}
{{- define "eric-eo-evnfm-library-chart.helm-annotations" -}}
ericsson.com/product-name: {{ (fromYaml (.Files.Get "eric-product-info.yaml")).productName | quote }}
ericsson.com/product-number: {{ (fromYaml (.Files.Get "eric-product-info.yaml")).productNumber | quote }}
ericsson.com/product-revision: {{ mustRegexFind "^([0-9]+)\\.([0-9]+)\\.([0-9]+)((-|\\+)EP[0-9]+)*((-|\\+)[0-9]+)*" .Chart.Version | quote }}
{{- end -}}

{{/*
Create Ericsson product app.kubernetes.io info
*/}}
{{- define "eric-eo-evnfm-library-chart.kubernetes-io-info" -}}
app.kubernetes.io/name: {{ .Chart.Name | quote }}
app.kubernetes.io/version: {{ .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" | quote }}
app.kubernetes.io/instance: {{ .Release.Name | quote }}
{{- end -}}

{{/*
Create pull policy for service
*/}}
{{- define "eric-eo-evnfm-library-chart.imagePullPolicy" -}}
    {{- $ctx := .ctx -}}
    {{- $svcRegistryName := .svcRegistryName -}}
    {{- if index $ctx "Values" "imageCredentials" $svcRegistryName -}}
        {{- if index $ctx "Values" "imageCredentials" $svcRegistryName "registry" -}}
            {{- if index $ctx "Values" "imageCredentials" $svcRegistryName "registry" "imagePullPolicy" -}}
                 {{- index $ctx "Values" "imageCredentials" $svcRegistryName "registry" "imagePullPolicy" -}}
            {{- end -}}
        {{- else if $ctx.Values.imageCredentials.pullPolicy -}}
            {{- print $ctx.Values.imageCredentials.pullPolicy -}}
        {{- else if $ctx.Values.global.registry.imagePullPolicy -}}
            {{- print $ctx.Values.global.registry.imagePullPolicy -}}
        {{- end -}}
    {{- else if $ctx.Values.global.registry.imagePullPolicy -}}
        {{- print $ctx.Values.global.registry.imagePullPolicy -}}
    {{- end -}}
{{- end -}}

{{/*
Create pull policy for pgInitContainer
*/}}
{{- define "eric-eo-evnfm-library-chart.pgInitContainer.imagePullPolicy" -}}
    {{- if .Values.imageCredentials.pgInitContainer -}}
        {{- if .Values.imageCredentials.pgInitContainer.registry -}}
            {{- if .Values.imageCredentials.pgInitContainer.registry.imagePullPolicy -}}
                 {{- print .Values.imageCredentials.pgInitContainer.registry.imagePullPolicy -}}
            {{- end -}}
        {{- else if .Values.imageCredentials.pgInitContainer.pullPolicy -}}
            {{- print .Values.imageCredentials.pgInitContainer.pullPolicy -}}
        {{- else if .Values.global.registry.imagePullPolicy -}}
            {{- print .Values.global.registry.imagePullPolicy -}}
        {{- end -}}
    {{- else if .Values.global.registry.imagePullPolicy -}}
        {{- print .Values.global.registry.imagePullPolicy -}}
    {{- end -}}
{{- end -}}

{{/*
Create a merged set of nodeSelectors from global and local/service level.
*/}}
{{- define "eric-eo-evnfm-library-chart.nodeSelector" -}}
  {{- $globalValue := (dict) -}}
  {{- if .Values.global -}}
    {{- if .Values.global.nodeSelector -}}
         {{- $globalValue = .Values.global.nodeSelector -}}
    {{- end -}}
  {{- end -}}
  {{- if .Values.nodeSelector -}}
    {{- range $key, $localValue := .Values.nodeSelector -}}
      {{- if hasKey $globalValue $key -}}
         {{- $Value := index $globalValue $key -}}
         {{- if ne $Value $localValue -}}
           {{- printf "nodeSelector \"%s\" is specified in both global (%s: %s) and service level (%s: %s) with differing values which is not allowed." $key $key $globalValue $key $localValue | fail -}}
         {{- end -}}
      {{- end -}}
    {{- end -}}
    {{- toYaml (merge $globalValue .Values.nodeSelector) | trim -}}
  {{- else -}}
    {{- if not ( empty $globalValue ) -}}
      {{- toYaml $globalValue | trim -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
The name of the cluster role used during openshift deployments.
This helper is provided to allow use of the new global.security.privilegedPolicyClusterRoleName if set, otherwise
use the previous naming convention of <name>-allowed-use-privileged-policy for backwards compatibility.
*/}}
{{- define "eric-eo-evnfm-library-chart.privileged.cluster.role.name" -}}
  {{- $ctx := .ctx -}}
  {{- $svcName := .svcName -}}
  {{- if hasKey ($ctx.Values.global.security) "privilegedPolicyClusterRoleName" -}}
    {{ $ctx.Values.global.security.privilegedPolicyClusterRoleName }}
  {{- else -}}
    {{- printf "%s-allowed-use-privileged-policy" $svcName -}}
  {{- end -}}
{{- end -}}

{{/*
Create Ericsson product specific annotations
*/}}
{{- define "eric-eo-evnfm-library-chart.helm-annotations_product_name" -}}
{{- $productname := (fromYaml (.Files.Get "eric-product-info.yaml")).productName -}}
{{- print $productname | quote }}
{{- end -}}
{{- define "eric-eo-evnfm-library-chart.helm-annotations_product_number" -}}
{{- $productNumber := (fromYaml (.Files.Get "eric-product-info.yaml")).productNumber -}}
{{- print $productNumber | quote }}
{{- end -}}
{{- define "eric-eo-evnfm-library-chart.helm-annotations_product_revision" -}}
{{- $ddbMajorVersion := mustRegexFind "^([0-9]+)\\.([0-9]+)\\.([0-9]+)((-|\\+)EP[0-9]+)*((-|\\+)[0-9]+)*" .Chart.Version -}}
{{- print $ddbMajorVersion | quote }}
{{- end -}}

{{/*
To support Dual stack.
*/}}
{{- define "eric-eo-evnfm-library-chart.internalIPFamily" -}}
{{- if  .Values.global -}}
  {{- if  .Values.global.internalIPFamily -}}
    {{- .Values.global.internalIPFamily | toString -}}
  {{- else -}}
    {{- "none" -}}
  {{- end -}}
{{- else -}}
{{- "none" -}}

{{- end -}}
{{- end -}}

{{- define "eric-eo-evnfm-library-chart.podPriority" -}}
{{- $ctx := .ctx -}}
{{- $svcName := .svcName -}}
{{- if $ctx.Values.podPriority -}}
  {{- if index $ctx "Values" "podPriority" $svcName -}}
    {{- index $ctx "Values" "podPriority" $svcName "priorityClassName" | toString -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
check global.security.tls.enabled
*/}}
{{- define "eric-eo-evnfm-library-chart.global-security-tls-enabled" -}}
{{- if  .Values.global -}}
  {{- if  .Values.global.security -}}
    {{- if  .Values.global.security.tls -}}
      {{- .Values.global.security.tls.enabled | toString -}}
    {{- else -}}
      {{- "false" -}}
    {{- end -}}
  {{- else -}}
    {{- "false" -}}
  {{- end -}}
{{- else -}}
  {{- "false" -}}
{{- end -}}
{{- end -}}

{{/*
DR-D1123-124
Evaluating the Security Policy Cluster Role Name
*/}}
{{- define "eric-eo-evnfm-library-chart.securityPolicy.reference" -}}
  {{- if .Values.global -}}
    {{- if .Values.global.security -}}
      {{- if .Values.global.security.policyReferenceMap -}}
        {{ $mapped := index .Values "global" "security" "policyReferenceMap" "default-restricted-security-policy" }}
        {{- if $mapped -}}
          {{ $mapped }}
        {{- else -}}
          default-restricted-security-policy
        {{- end -}}
      {{- else -}}
        default-restricted-security-policy
      {{- end -}}
    {{- else -}}
      default-restricted-security-policy
    {{- end -}}
  {{- else -}}
    default-restricted-security-policy
  {{- end -}}
{{- end -}}

{{/*
Create volume permissions image registry url
*/}}
{{- define "eric-eo-evnfm-library-chart.volumePermissionsImagePath" -}}
    {{- $productInfo := fromYaml (.Files.Get "eric-product-info.yaml") -}}
    {{- $registryUrl := $productInfo.images.volumePermissions.registry -}}
    {{- $repoPath := $productInfo.images.volumePermissions.repoPath -}}
    {{- $name := $productInfo.images.volumePermissions.name -}}
    {{- $tag := $productInfo.images.volumePermissions.tag -}}
    {{- if .Values.global -}}
        {{- if .Values.global.registry -}}
            {{- if .Values.global.registry.url -}}
                {{- $registryUrl = .Values.global.registry.url -}}
            {{- end -}}
        {{- end -}}
    {{- end -}}
    {{- if .Values.imageCredentials -}}
        {{- if .Values.imageCredentials.volumePermissions -}}
            {{- if .Values.imageCredentials.volumePermissions.registry -}}
                {{- if .Values.imageCredentials.volumePermissions.registry.url -}}
                    {{- $registryUrl = .Values.imageCredentials.volumePermissions.registry.url -}}
                {{- end -}}
            {{- end -}}
            {{- if not (kindIs "invalid" .Values.imageCredentials.volumePermissions.repoPath) -}}
                {{- $repoPath = .Values.imageCredentials.volumePermissions.repoPath -}}
            {{- end -}}
        {{- end -}}
        {{- if not (kindIs "invalid" .Values.imageCredentials.repoPath) -}}
            {{- $repoPath = .Values.imageCredentials.repoPath -}}
        {{- end -}}
    {{- end -}}
    {{- if $repoPath -}}
        {{- $repoPath = printf "%s/" $repoPath -}}
    {{- end -}}
    {{- printf "%s/%s%s:%s" $registryUrl $repoPath $name $tag -}}
{{- end -}}

{{/*
 create prometheus info
*/}}
{{- define "eric-eo-evnfm-library-chart.prometheus" -}}
prometheus.io/path: "{{ .Values.prometheus.path }}"
prometheus.io/port: "{{ .Values.container.ports.http }}"
prometheus.io/scrape: "{{ .Values.prometheus.scrape }}"
prometheus.io/scrape-role: "{{ index .Values "prometheus" "scrape-role" }}"
prometheus.io/scrape-interval: "{{ index .Values "prometheus" "scrape-interval" }}"
{{- end -}}

{{/*
Create fsGroup Values DR-1123-136
*/}}
{{- define "eric-eo-evnfm-library-chart.fsGroup" -}}
  {{- if .Values.global -}}
    {{- if .Values.global.fsGroup -}}
      {{- if .Values.global.fsGroup.manual -}}
        {{ .Values.global.fsGroup.manual | int }}
      {{- else -}}
        {{- if eq .Values.global.fsGroup.namespace true -}}
          # The 'default' defined in the Security Policy will be used.
        {{- else -}}
          10000
        {{- end -}}
      {{- end -}}
    {{- else -}}
        10000
    {{- end -}}
  {{- else -}}
    10000
  {{- end -}}
{{- end -}}

{{/*
DR-D470222-010
Configuration of Log Collection Streaming Method
*/}}
{{- define "eric-eo-evnfm-library-chart.log.streamingMethod" -}}
{{- $defaultMethod := "dual" }}
{{- $streamingMethod := (.Values.log).streamingMethod }}
    {{- if not $streamingMethod }}
        {{- if (.Values.global.log).streamingMethod -}}
            {{- $streamingMethod = (.Values.global.log).streamingMethod }}
        {{- else -}}
            {{- $streamingMethod = $defaultMethod -}}
        {{- end }}
    {{- end }}

    {{- if or (eq $streamingMethod "direct") (eq $streamingMethod "indirect") }}
        {{- $streamingMethod -}}
    {{- else }}
        {{- $defaultMethod -}}
    {{- end }}
{{- end }}

{{/*
 DR-D1120-056-AD
In order for the ADP Service to be able to properly deal with voluntary disruptions,
it SHALL specify the number/percentage of Pods
that must remain available during such disruptions by using Pod Disruption Budget (PDB).
*/}}
{{- define "eric-eo-evnfm-library-chart.PodDisruptionBudget" -}}
{{- if .Values.podDisruptionBudget }}
{{- if and ( empty .Values.podDisruptionBudget.minAvailable ) ( empty .Values.podDisruptionBudget.maxUnavailable )}}
minAvaliable: "50%"
{{- else }}
{{- if .Values.podDisruptionBudget.minAvailable}}
minAvaliable: {{ .Values.podDisruptionBudget.minAvailable }}
{{- end -}}
{{- if .Values.podDisruptionBudget.maxUnavailable }}
maxUnavailable: {{ .Values.podDisruptionBudget.maxUnavailable }}
{{- end }}
{{- end }}
{{- else }}
minAvaliable: "50%"
{{- end }}
{{- end -}}

{{/*
DR-D1123-133
Standardized secret file names for certificates.
*/}}
{{- define "tls.secret.trustedInternalRootCa" -}}
  {{- if (((.Values.global.security).tls).trustedInternalRootCa).secret -}}
    {{ .Values.global.security.tls.trustedInternalRootCa.secret }}
  {{- else -}}
    eric-sec-sip-tls-trusted-root-cert
  {{- end -}}
{{- end -}}

{{/*
DR-D1123-134
Rolekind parameter for generation of role bindings for admission control in OpenShift environment
*/}}
{{- define "eric-eo-evnfm-library-chart.securityPolicy.rolekind" }}
    {{- if .Values.global.securityPolicy }}
        {{- if .Values.global.securityPolicy.rolekind }}
            {{- (.Values.global.securityPolicy).rolekind }}
        {{- end }}
    {{- end }}
{{- end }}

{{/*
DR-D1123-134
Rolename parameter for generation of role bindings for admission control in OpenShift environment
*/}}
{{- define "eric-eo-evnfm-library-chart.securityPolicy.rolename" }}
    {{- if .Values.global.securityPolicy }}
        {{- if (.Values.securityPolicy).rolename }}
            {{- (.Values.securityPolicy).rolename }}
        {{- else }}
            {{- if .Values.global.security.privilegedPolicyClusterRoleName }}
                {{- .Values.global.security.privilegedPolicyClusterRoleName }}
            {{- else }}
                {{- .Values.nameOverride }}
            {{- end }}
        {{- end }}
    {{- end }}
{{- end }}

{{/*
DR-D1123-134
RoleBinding name for generation of role bindings for admission control in OpenShift environment
*/}}
{{- define "eric-eo-evnfm-library-chart.securityPolicy.rolebinding.name"}}
    {{- $roleKind := include "eric-eo-evnfm-library-chart.securityPolicy.rolekind" . }}
    {{- $roleName := include "eric-eo-evnfm-library-chart.securityPolicy.rolename" . }}
    {{- $serviceName := .Values.nameOverride }}
    {{- if and $roleName $roleKind }}
        {{- if $roleKind }}
            {{- $roleKind = (cat "-" ($roleKind | substr 0 1 | lower )) }}
        {{- end }}
        {{- if $roleName }}
            {{- $roleName = (cat "-" $roleName) }}
        {{- end}}
        {{- $serviceName = nospace (cat $serviceName "-sa" $roleKind $roleName) }}
    {{- end }}
    {{- $serviceName }}
{{- end }}