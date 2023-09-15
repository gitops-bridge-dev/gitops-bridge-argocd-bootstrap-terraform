{{/*
  ParentAppend <Template>
*/}}
{{- define "lib.utils.dicts.parentAppend" -}}
  {{- $baseDict := dict -}}
  {{- $_ := set $baseDict (default .key "Values") (default . .append) -}}
  {{- toYaml $_ | indent 0 }}
{{- end -}}


{{/*
  PrintYamlStructure <Template>
*/}}
{{- define "lib.utils.dicts.printYAMLStructure" -}}
  {{- if .structure }}
    {{ $structure := trimAll "." .structure }}
    {{- $i := 0 }}
    {{- if $structure }}
      {{- range (splitList "." $structure) }}
        {{- . | nindent (int $i) }}:
        {{- $i = add $i 2 }}
      {{- end }}
    {{- end }}
    {{- if .data }}
      {{- .data | nindent (int $i) }}
    {{- end }}
  {{- end }}
{{- end -}}

{{/*
  Get <Template>
*/}}
{{- define "lib.utils.dicts.get" -}}
  {{- $result := dict "res" dict -}}
  {{- $path := trimAll "." .path -}}
  {{- if and $path .data -}}
    {{- $buf := .data -}}
    {{- $miss := dict "state" false "path" -}}
    {{- range $p := (splitList "." $path) -}}
      {{- $p = $p | replace "$" "." -}}
      {{- if eq $miss.state false -}}
        {{- if (hasKey $buf $p) -}}
          {{- $buf = get $buf $p -}}
        {{- else -}}
          {{- $_ := set $miss "path" $p -}}
          {{- $_ := set $miss "state" true -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
    {{- if eq $miss.state false -}}
      {{- printf "%s" (toYaml (dict "res" $buf)) -}}
    {{- else -}}
      {{- if eq (default false .required) true -}}
        {{ include "lib.utils.errors.fail" (cat "Missing path" $miss.path "for get" $path "in structure\n" (toYaml .data | nindent 0)) }}
      {{- else -}}
        {{- printf "%s" (toYaml $result) -}}
      {{- end -}}
    {{- end -}}
  {{- else -}}
    {{- printf "%s" (toYaml $result) -}}
  {{- end -}}
{{- end -}}

{{/*
  Unset <Template>
*/}}
{{- define "lib.utils.dicts.unset" -}}
  {{- $path := trimAll "." $.path -}}
  {{- if and $path $.data -}}
    {{- $buf := $.data -}}
    {{- $paths := (splitList "." $path) -}}
    {{- range $p := $paths -}}
      {{- $p = $p | replace "$" "." -}}
      {{- if (hasKey $buf $p) }}
        {{- if eq (last $paths) $p -}}
          {{- $_ := unset $buf $p -}}
        {{- else -}}
          {{- $buf = get $buf $p -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
  Set <Template>
*/}}
{{- define "lib.utils.dicts.set" -}}
  {{- $path := trimAll "." .path -}}
  {{- if and $path $.data $.value -}}
    {{- $buf := .data -}}
    {{- $paths := (splitList "." $path) -}}
    {{- range $p := $paths -}}
      {{- $p = $p | replace "$" "." -}}
      {{- if eq $p (last $paths) -}}
        {{- if (kindIs "map" $.value) -}}
          {{- include "lib.utils.dicts.merge" (dict "base" (default dict (get $buf $p)) "data" $.value) -}}
        {{- else -}}
          {{- $_ := set $buf $p $.value -}}
        {{- end -}}
      {{- else -}}
        {{- if not (hasKey $buf $p) -}}
          {{- $_ := set $buf $p dict -}}
        {{- end -}}
        {{- $buf = get $buf $p -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}



{{/*
  Merge <Template>
*/}}
{{- define "lib.utils.dicts.merge" -}}
  {{- $base := $.base -}}

  {{/* Merge Options */}}
  {{- $inject_key := (include "lib.utils.dicts.merge.int.inject_key" $) -}}

  {{/* Check if Maps */}}
  {{- if $.data -}}

    {{/* Iterate over Keys */}}
    {{- range $key, $data := $.data -}}
  
      {{/* Overwrite if not set */}}
      {{- $base_data := (get $base $key) -}}
      {{- if $base_data -}}
  
        {{/* if types don't match the key is overwritten */}}
        {{- if (eq (kindOf $data) (kindOf $base_data)) -}}
          {{/* Compare Types */}}
          {{- if (kindIs "map" $data) -}}
  
            {{/* Recursive Call */}}
            {{- include "lib.utils.dicts.merge" (dict "base" $base_data "data" $data "injectKey" $inject_key "ctx" $.ctx) -}}
          
          {{/* Handle List merges */}}
          {{- else if (kindIs "slice" $data) -}}
  
              {{/* Evaluate Merge Key */}}
              {{- $merge_key := "name" -}}
              {{- range $u := (get $.data $key) -}}
                {{- if (kindIs "string" $u) -}}
  
                  {{/* Match on Expression ((*)) */}}
                  {{- $merge_exp := regexFind "\\(\\(.*\\)\\)" $u  -}}
                  {{- if $merge_exp -}}
  
                    {{/* Format Merge Key */}}
                    {{- $f_key := ($merge_exp | nospace | replace "(" "" | replace ")" "" ) -}}
                    {{- if $f_key -}}
                      {{- $merge_key = $f_key -}}
                    {{- end -}}
  
                    {{/* Remove Key Anyway */}}
                    {{- $_ := set $.data $key (without (get $.data $key) $merge_exp) -}}
  
                  {{- end -}}
                {{- end -}}
              {{- end -}}
  
              {{/* Unmatched Base References */}}
              {{- $unmatched_base := list -}}
              {{- $unmatched_data := (get $.data $key) -}}
              
              {{/* Range Over Base (This way we can remove unmatched entries) */}}
              {{- range $i, $base_leaf := $base_data -}}
                {{- $merged := 1 -}}
  
                {{- if (kindIs "map" $base_leaf) -}}
  
                  {{- range $leaf := (get $.data $key) -}}
                    {{- if (kindIs "map" $leaf) -}}
                        {{/* Validate if Key Same */}}
                        {{- if eq ((get $leaf $merge_key) | toString) ((get $base_leaf $merge_key) | toString) -}}
    
                          {{/* Remove Leaf on Data */}}
                          {{- $unmatched_data = without $unmatched_data $leaf -}}
                          {{- $merged = 0 -}}
    
                          {{/* Recursion */}}
                          {{- include "lib.utils.dicts.merge" (dict "base" $base_leaf "data" $leaf "injectKey" $inject_key "ctx" $.ctx) -}}
    
                        {{- end -}}
                    {{- end -}}
                  {{- end -}}
                {{- end -}}
  
                {{/* Append Unmerged Leafs to base */}}
                {{- if $merged -}}
                  {{- $unmatched_base = append $unmatched_base $base_leaf -}}
                {{- end -}}
              {{- end -}}
  
              {{/* Remove Unmatched From Base List */}}
              {{- range $u := $unmatched_base -}}
                {{- $_ := set $base $key (without (get $base $key) $u) -}}
              {{- end -}}
  
              {{/* Add Unmatched from Data */}}
              {{- range $u := $unmatched_data -}}
                {{- $_ := set $base $key (append (get $base $key) $u) -}}
              {{- end -}}
  
  
              {{/* Data Injector */}}
              {{- $injected := 0 -}}
              {{- range $i, $base_leaf := (get $base $key) -}}
                {{- if and (kindIs "string" $base_leaf) (not $injected)  -}}
                  {{- if (eq ($base_leaf | lower) $inject_key) -}}
  
                    {{/* Inject on Unmatched Base Data */}}
                    {{- if $unmatched_base -}}
                      {{- $tmp := list -}}
  
                      {{/* First Entry */}}
                      {{- if (eq $i 0) -}}
                        {{- $tmp = concat $unmatched_base (get $base $key) -}}
                      {{/* Inject Within List */}}
                      {{- else -}}
                        {{- $partial_list := slice (get $base $key) 0 $i -}}
                        {{- $partial_list = concat $partial_list $unmatched_base -}}
                        {{- $partial_list = concat $partial_list (slice (get $base $key) $i) -}}
                        {{- $tmp = $partial_list -}}
                      {{- end -}}
  
                      {{- $injected = 1 -}}
  
                      {{/* Redirect Injected Slice */}}
                      {{- $_ := set $base $key $tmp -}}
  
                    {{- end -}}
                  {{- end -}}
                {{- end -}}
              {{- end -}}
  
              {{/* Remove Inject Key Anyway (Must Remove on Both Dicts) */}}
              {{- $_ := set $.data $key (without (get $.data $key) $inject_key) -}}
              {{- $_ := set $base $key (without (get $base $key) $inject_key) -}}
           
          {{/* Redirect Data */}}
          {{- else -}}
            {{- include "lib.utils.dicts.merge.int.redirect" (dict "base" $base "data" $data "key" $key "ctx" $.ctx) -}}
          {{- end -}}
        {{/* Overwrite */}}
        {{- else -}}
          {{- include "lib.utils.dicts.merge.int.redirect" (dict "base" $base "data" $data "key" $key "ctx" $.ctx) -}}
        {{- end -}}
      {{/* Overwrite */}}
      {{- else -}}
        {{- include "lib.utils.dicts.merge.int.redirect" (dict "base" $base "data" $data "key" $key "ctx" $.ctx) -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{/*
  Redirect <Internal Template>
    Format Data Before Redirecting 
*/}}
{{- define "lib.utils.dicts.merge.int.redirect" -}}
  {{- if (kindIs "slice" $.data) -}}
    {{- $_ := set $ "data" (without $.data (include "lib.utils.dicts.merge.int.inject_key" $)) -}}
    {{- range $d := $.data -}}
      {{- if (kindIs "string" $d) -}}
        {{- $mk := include "lib.utils.dicts.merge.int.merge_key" $d -}}
        {{- if $mk -}}
          {{- $_ := set $ "data" (without $.data $mk) -}}
        {{- end -}}
      {{- end -}}
    {{- end -}}
  {{- end -}}
  {{- $_ := set $.base $.key $.data -}}
{{- end -}}

{{/*
  Inject Key <Internal Template>
*/}}
{{- define "lib.utils.dicts.merge.int.inject_key" -}}
__inject__
{{- end -}}

{{/*
  Merge Key <Internal Template>
*/}}
{{- define "lib.utils.dicts.merge.int.merge_key" -}}
  {{/* Regex for Lookup */}}
  {{- $merge_exp := regexFind "\\(\\(.*\\)\\)" $ -}}
  {{- if $merge_exp -}}
    {{- printf "%s" ($merge_exp) -}}
  {{- end -}}
{{- end -}}
