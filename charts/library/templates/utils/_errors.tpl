{{/*
  Fail <Template>
*/}}
{{- define "lib.utils.errors.fail" -}}
  {{- fail (printf "\n\n%s" $) -}}
{{- end -}}  


{{/*
  unmarshalingError <Template>
*/}}
{{- define "lib.utils.errors.unmarshalingError" -}}
  {{- if $.Error -}}
    {{- true -}}
  {{- end -}}
{{- end -}}  

{{/*
  params <Template>
*/}} 
{{- define "lib.utils.errors.params" -}}
  {{- include "lib.utils.errors.fail" (printf "Template %s requires the following parameters: %s" (default "" $.tpl) ($.params | join ", ")) -}}
{{- end -}}