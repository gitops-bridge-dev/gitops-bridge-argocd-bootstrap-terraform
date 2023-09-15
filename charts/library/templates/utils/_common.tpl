{{/*
  Sprig Template - ReleaseName
*/}}
{{- define "lib.internal.common.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}


{{/*
  Sprig Template - Name
*/}}
{{- define "lib.internal.common.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
  Sprig Template - Release.Name Compare
*/}}
{{- define "lib.internal.common.releaseNameCompare" -}}
  {{- if .name }}
    {{- if or (contains .name .context.Release.Name) (contains .context.Release.Name .name) -}}
        {{- printf "%s" .name -}}
    {{- else -}}
        {{- printf "%s-%s" .context.Release.Name .name -}}
    {{- end -}}
  {{- else }}
    {{- printf "%s" .context.Release.Name -}}
  {{- end -}}  
{{- end -}}

{{/*
  Sprig Template - Name add Prefix
*/}}
{{- define "lib.internal.common.prefix" -}}
  {{- if .prefix  -}}
    {{- printf "%s-%s" .prefix .name -}}
  {{- else -}}
    {{- printf "%s" .name -}}
  {{- end -}}
{{- end -}}


{{/*
  Sprig Template - Fullname
*/}}
{{- define "lib.utils.common.fullname" -}}
  {{- $context := default . .context -}}
  {{- $name := default $context.name .name -}}
  {{- $fullname := default $context.fullname .fullname  -}}
  {{- $prefix := default $context.prefix .prefix }}
  {{- $return := "" -}}
  {{- if $context.Values.fullnameOverride -}}
    {{- $return = include "lib.internal.common.prefix" (dict "prefix" $prefix "name" $context.Values.fullnameOverride) -}}
  {{- else if $fullname }}
    {{- $return = include "lib.internal.common.prefix" (dict "prefix" $prefix "name" $fullname) -}}
  {{- else if $name }}
    {{- $return = include "lib.internal.common.prefix" (dict "prefix" $prefix "name" (include "lib.internal.common.releaseNameCompare" (dict "name" $name "context" $context))) -}}
  {{- else if $context.Values.fullnameOverride -}}
    {{- $return = include "lib.internal.common.prefix" (dict "prefix" $prefix "name" $context.Values.fullnameOverride) -}}
  {{- else }}
    {{- $return = include "lib.internal.common.prefix" (dict "prefix" $prefix "name" (include "lib.internal.common.releaseNameCompare" (dict "name" (include "lib.internal.common.name" $context) "context" $context))) -}}
  {{- end -}}
  {{- if (contains "RELEASE-NAME" $return) }}
    {{- printf "%s" $return }}
  {{- else }}
    {{- printf "%s" (include "lib.utils.strings.toDns1123" $return) }}
  {{- end }}
{{- end -}}

{{/*
  Sprig Template - BaseLabels
*/}}
{{- define "lib.utils.common.defaultSelectorLabels" -}}
app.kubernetes.io/name: {{ include "lib.utils.common.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
  Sprig Template - SelectorLabels
*/}}
{{- define "lib.utils.common.selectorLabels" -}}
  {{- if $.Values.selectorLabels }}
  {{- include "lib.utils.strings.template" (dict "value" $.Values.selectorLabels "context" $) | indent 0 }}
  {{- else }}
{{- include "lib.utils.common.defaultSelectorLabels" $ | nindent 0 }}
  {{- end }}
{{- end -}}

{{/*
  Sprig Template - DefaultLabels
*/}}
{{- define "lib.utils.common.defaultLabels" -}}
{{- include "lib.utils.common.defaultSelectorLabels" $ | nindent 0 }}
  {{- if and .Chart.AppVersion (not .versionunspecific) }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
  {{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ include "lib.internal.common.chart" $ }}
{{- end -}}

{{/*
  Sprig Template - CommonLabels
*/}}
{{- define "lib.utils.common.commonLabels" -}}
  {{- if and $.Values.overwriteLabels (kindIs "map" $.Values.overwriteLabels) }}
    {{- include "lib.utils.strings.template" (dict "value" $.Values.overwriteLabels "context" $) | nindent 0 }}
  {{- else }}
    {{- include "lib.utils.common.defaultLabels" . | indent 0 }}
    {{- if and $.Values.commonLabels (kindIs "map" $.Values.commonLabels) }}
      {{- include "lib.utils.strings.template" (dict "value" $.Values.commonLabels "context" $) | nindent 0 }}
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
  Sprig Template - Labels
*/}}
{{- define "lib.utils.common.labels" -}}
  {{- $_ := set (default . .context) "versionunspecific" (default false .versionUnspecific ) -}}
  {{- toYaml (mergeOverwrite (fromYaml (include "lib.utils.common.commonLabels" (default . .context))) (default dict .labels)) | indent 0 }}
  {{- $_ := unset (default . .context) "versionunspecific" }}
{{- end -}}

{{/*
  Sprig Template - KubernetesCapabilities
*/}}
{{- define "lib.utils.common.capabilities" -}}
  {{- $capability := $.Capabilities.KubeVersion.Version -}}
  {{- if .Values.global -}}
    {{- if $.Values.global.kubeCapabilities -}}
      {{- $capability = $.Values.global.kubeCapabilities -}}
    {{- end -}}
  {{- end -}}
  {{- printf "%s" $capability -}}
{{- end -}}