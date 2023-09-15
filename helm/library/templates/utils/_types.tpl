{{/* 
  Validate <Template> 
*/}}
{{- define "lib.utils.types.validate" -}}
  {{- if $.ctx -}}
    {{- $return := dict "isType" 1 "errors" list  -}}
    {{- $type := dict -}}
    {{- $type_raw := dict -}}

    {{/* Source Type */}}
    {{- if $.properties -}}
      {{- $type = $.properties -}}
    {{- else -}}
      {{- if $.type -}}
        {{- $type_raw = include $.type $.ctx -}}
        {{- $type = fromYaml ($type_raw) -}}
      {{- end -}}
    {{- end -}}

    {{- if $type -}}
      {{- if not (include "lib.utils.errors.unmarshalingError" $type) -}}
        {{- range $field, $prop := $type -}}
  
          {{/* Get Field */}}
          {{- $d_field := get $.data $field -}}
  
          {{- if (hasKey $prop "_props") -}}

            {{- $raw_prop_type := include "lib.utils.types.validate" (dict "data" (default dict $d_field) "properties" $prop._props "validate" $.validate "ctx" $.ctx) -}}
            {{- $prop_type := fromYaml ($raw_prop_type)  -}}

            {{- $_ := set $return "isType" $prop_type.isType -}}
            {{- if not ($prop_type.isType) -}}
              {{- $_ := set $return "errors" (concat $return.errors (default list $prop_type.errors)) -}}
            {{- end -}}
  
          {{- else -}}
  
            {{/* Assign Default if not present, skip if validate only mode */}}
            {{- if not ($.validate) -}}
              {{- if (ne (toString $d_field) "false") -}}
                {{- if and (not $d_field) (or ($prop.default) (eq (toString $prop.default) "false")) -}}
                  {{- $d_field = $prop.default -}}
                  {{- $_ := set $.data $field $prop.default -}}
                {{- end -}}   
              {{- end -}}
            {{- end -}}
  
            {{/* Validate */}}
            {{- if or $d_field (eq (toString $d_field) "false") -}}
    
              {{/* Values Comparison */}}
              {{- if $prop.values -}}
    
                {{/* Convert types to list */}}
                {{- if not (kindIs "slice" $prop.values) -}}
                  {{- $_ := set $prop "values" (list $prop.values) -}}
                {{- end -}}
    
                {{/* Check for each kind */}}
                {{- $isValue := 0 -}}
                {{- range $prop.values -}}
                  {{- if (eq (. | toString) ($d_field | toString)) -}}
                    {{- $isValue = 1 -}}
                  {{- end -}}
                {{- end -}}
    
                {{/* Check if Value was valid */}}
                {{- if not $isValue -}}
                  {{- $_ := set $return "isType" 0 -}}
                  {{- $_ := set $return "errors" (append $return.errors (dict "error" (printf "Field %s did not match any of these values: %s" $field ($prop.values | join ", ")))) -}}
                {{- end -}}
    
              {{- end -}}
    
      
              {{/* Type Comparison */}}
              {{- if $prop.types -}}
      
                {{/* Convert types to list */}}
                {{- if not (kindIs "slice" $prop.types) -}}
                  {{- $_ := set $prop "types" (list $prop.types) -}}
                {{- end -}}
      
                {{/* Check for each kind */}}
                {{- $isKind := 0 -}}
                {{- range $prop.types -}}
                  {{- if (kindIs . $d_field) -}}
                    {{- $isKind = 1 -}}
                  {{- end -}}
                {{- end -}}
      
                {{/* Check if Kind was valid */}}
                {{- if not $isKind -}}
                  {{- $_ := set $return "isType" 0 -}}
                  {{- $_ := set $return "errors" (append $return.errors (dict "error" (printf "Field %s did not match any of these types: %s" $field ($prop.types | join ", ")))) -}}
                {{- end -}}
      
              {{- end -}}
            {{- else -}}
    
              {{/* When field does not exist, check if it's required */}}
              {{- if $prop.required -}}
                {{- $_ := set $return "isType" 0 -}}
                {{- $_ := set $return "errors" (append $return.errors (dict "error" (printf "Field %s is required but not set" $field))) -}}
              {{- end -}}

            {{- end -}}
          {{- end -}}
        {{- end -}}
      {{- else -}}
        {{- include "lib.utils.errors.fail" (printf "Type Template %s did not return valid YAML:\n%s" $.type ($type_raw | nindent 2)) -}}
      {{- end -}}

      {{/* Return */}}
      {{- printf "%s" (toYaml $return) -}}

    {{- else -}}

      {{- include "lib.utils.errors.fail" "Empty Type Declaration" -}}

    {{- end -}}
  {{- else -}}
    {{- include "lib.utils.errors.params" (dict "tpl" "lib.utils.types.validate" "params" (list "type" "data" "ctx")) -}}
  {{- end -}}
{{- end -}}