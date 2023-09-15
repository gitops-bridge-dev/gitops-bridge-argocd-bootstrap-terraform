{{/*
  Template <Template>
*/}}
{{- define "lib.utils.strings.template" -}}
  {{- if .context }}
    {{- $_ := set .context (default "extraVars" .extraValuesKey) (default dict .extraValues) }}
    {{- if typeIs "string" .value }}
        {{- tpl .value .context  | replace "+|" "\n" }}
    {{- else }}
        {{- tpl (.value | toYaml) .context | replace "+|" "\n" }}
    {{- end }}
    {{- $_ := unset .context (default "extraVars" .extraValuesKey) }}
  {{- else }}
    {{- include "lib.utils.errors.params" (dict "tpl" "lib.utils.strings.template" "params" (list "context")) -}}
  {{- end }}
{{- end -}}

{{/*
  Stringify <Template>
*/}}
{{- define "lib.utils.strings.stringify" -}}
  {{- if and .list .context }}
    {{- $delimiter := (default " " .delimiter) -}}
    {{- if kindIs "slice" .list }}
        {{- printf "%s" (include "lib.utils.strings.template" (dict "value" (.list | join $delimiter) "context" .context)) | indent 0 }}
    {{- end }}
  {{- else }}
    {{- include "lib.utils.errors.params" (dict "tpl" "lib.utils.strings.stringify" "params" (list "list" "context")) -}}
  {{- end }}
{{- end }}

{{/* 
  ToDns1123 <Template> 
*/}}
{{- define "lib.utils.strings.toDns1123" -}}
  {{- if (kindIs "string" .) }}
    {{- printf "%s" (regexReplaceAll "[^a-z0-9-.]" (lower .) "${1}-") | trunc 63 | trimSuffix "-" | trimPrefix "-" }}
  {{- else }}
    {{- . }}
  {{- end }}
{{- end }}
