{{/*
  HasValueByKey <Template>
*/}}
{{- define "lib.utils.lists.hasValueByKey" -}}
  {{- if .value }}
    {{- if .list }}
      {{- $key := default "name" .key }}
      {{- if (kindIs "slice" .list) }}
        {{- range .list }}
          {{- if . }}
            {{- if eq (get . $key) $.value -}}
              {{- true -}}
            {{- end }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
  GetValueByKey <Template>
*/}}
{{- define "lib.utils.lists.getValueByKey" -}}
  {{- if and .list .value }}
    {{- if .list }}
      {{- $key := default "name" .key }}
      {{- if (kindIs "slice" .list) }}
        {{- range .list }}
          {{- if . }}
            {{- if eq (get . $key) $.value -}}
              {{- toYaml . | indent 0 }}
            {{- end }}
          {{- end }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
  MergeList <Template>
*/}}
{{- define "lib.utils.lists.mergeList" -}}
    {{- $mergedList := (concat (default list (index . 0)) (default list (index . 1)) | uniq) -}}
    {{- if gt (len $mergedList) 0 }}
        {{- toYaml $mergedList | indent 0 }}
    {{- end }}
{{- end -}}

{{/*
  MergeListOnKey <Template>
*/}}
{{- define "lib.utils.lists.mergeListOnKey" -}}
  {{- if and (and .source (kindIs "slice" .source)) (and .target (kindIs "slice" .target)) }}
    {{- $cache := dict "output" list "input" (dict "onKey" (default "name" .key) "refList" .source "targetList" .target) "keys" (dict "allyKeys" list "refKeyList" list "targetKeyList" list "overlappingKeyList" list) "lists" (dict "overlappingItems" list "refListFilter" list "targetListFilter" list)}}
    {{- range $cache.input.refList }}
      {{- if (hasKey . $cache.input.onKey) }}
        {{- $_ := set $cache.keys "refKeyList" (append $cache.keys.refKeyList (get . $cache.input.onKey)) }}
      {{- end }}
    {{- end }}
    {{- range $cache.input.targetList  }}
      {{- if (hasKey . $cache.input.onKey) }}
        {{- $_ := set $cache.keys "targetKeyList" (append $cache.keys.targetKeyList (get . $cache.input.onKey)) }}
      {{- end }}
    {{- end }}
    {{- $_ := set $cache.keys "allKeys" (concat $cache.keys.refKeyList $cache.keys.targetKeyList | uniq) }}
    {{- if $cache.keys.allKeys }}
      {{- range $cache.keys.allKeys }}
        {{- if and (has . $cache.keys.refKeyList) (has . $cache.keys.targetKeyList) }}
          {{- $_ := set $cache.keys "overlappingKeyList" (append $cache.keys.overlappingKeyList . | uniq) }}
        {{- end }}
      {{- end }}
      {{- if $cache.keys.overlappingKeyList }}
        {{- range $cache.keys.overlappingKeyList }}
          {{- $_ := set $cache.lists "overlappingItems" (append $cache.lists.overlappingItems (merge (fromYaml (include "lib.utils.lists.getValueByKey" (dict "list" $cache.input.refList "value" .))) (fromYaml (include "lib.utils.lists.getValueByKey" (dict "list" $cache.input.targetList "value" .))))) }}
        {{- end }}
        {{- range $cache.input.refList }}
          {{- if not (has (get . $cache.input.onKey) $cache.keys.overlappingKeyList) }}
            {{- $_ := set $cache.lists "refListFilter" (append $cache.lists.refListFilter (fromYaml (include "lib.utils.lists.getValueByKey" (dict "list" $cache.input.refList "value" (get . $cache.input.onKey))))) }}
          {{- end }}
        {{- end }}
        {{- range $cache.input.targetList }}
          {{- if not (has (get . $cache.input.onKey) $cache.keys.overlappingKeyList) }}
            {{- $_ := set $cache.lists "targetListFilter" (append $cache.lists.targetListFilter (fromYaml (include "lib.utils.lists.getValueByKey" (dict "list" $cache.input.targetList "value" (get . $cache.input.onKey))))) }}
          {{- end }}
        {{- end }}
        {{- $_ := set $cache "output" (concat $cache.lists.refListFilter $cache.lists.targetListFilter $cache.lists.overlappingItems) }}
      {{- else }}
        {{- $_ := set $cache "output" (concat $cache.input.refList $cache.input.targetList) }}
      {{- end }}
      {{- if .parentKey }}
        {{- .parentKey | nindent 0 }}: {{- toYaml $cache.output | nindent 2 }}
      {{- else }}
        {{- toYaml $cache.output | nindent 0 }}
      {{- end }}
    {{- end }}
  {{- else }}
    {{- if and (and .source (kindIs "slice" .source)) }}
      {{- if .parentKey }}
        {{- .parentKey | nindent 0 }}: {{- toYaml .source | nindent 2 }}
      {{- else }}
        {{- toYaml .source | nindent 0 }}
      {{- end }}
    {{- else }}
      {{- if .parentKey }}
        {{- .parentKey | nindent 0 }}: {{- toYaml .target | nindent 2 }}
      {{- else }}
        {{- toYaml .target | nindent 0 }}
      {{- end }}
    {{- end }}
  {{- end }}
{{- end }}


{{/*
  ExceptionList <Template>
*/}}
{{- define "lib.utils.lists.exceptionList" -}}
  {{- if and .list (kindIs "slice" .list) }}
    {{- if .exceptions }}
      {{- $key := (default "name" .key) }}
      {{- $context := .context }}
      {{- $filteredList := list }}
      {{- $exceptionList := list }}
      {{- if kindIs "slice" .exceptions }}
        {{- $exceptionList = .exceptions }}
      {{- else }}
        {{- $exceptionList = (splitList " " .exceptions) }}
      {{- end }}
      {{- range .list  }}
        {{- if kindIs "map" . }}
          {{- if not (has (get . $key) $exceptionList) -}}
            {{- $filteredList = append $filteredList . -}}
          {{- end }}
        {{- else }}
          {{- $filteredList = append $filteredList . -}}
        {{- end }}
      {{- end }}
      {{- toYaml $filteredList  | indent 0 }}
    {{- else }}
      {{- toYaml list | nindent 0 }}
    {{- end }}
  {{- end }}
{{- end -}}
