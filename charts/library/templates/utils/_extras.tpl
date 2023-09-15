{{/*
  ExtraEnvironment <Template>
*/}}
{{- define "lib.utils.extras.environment" -}}
- name: NODE_NAME
  valueFrom:
    fieldRef:
      fieldPath: spec.nodeName
- name: POD_NAME
  valueFrom:
    fieldRef:
      fieldPath: metadata.name
- name: POD_NAMESPACE
  valueFrom:
    fieldRef:
      fieldPath: metadata.namespace
- name: POD_IP
  valueFrom:
    fieldRef:
      fieldPath: status.podIP
- name: POD_SERVICE_ACCOUNT
  valueFrom:
    fieldRef:
      fieldPath: spec.serviceAccountName
  {{- if $.Values.global -}}
    {{- with $.Values.global.timezone }}
- name: "TZ"
  value: "{{ . }}"
    {{- end }}
    {{- with $.Values.global.proxy }}
      {{- $proxy := (fromYaml (include "lib.utils.strings.template" (dict "value" $.Values.global.proxy "context" $))) }}
      {{- if $proxy.httpProxy }}
        {{- if and ($proxy.httpProxy.host) ($proxy.httpProxy.port) }}
- name: "HTTP_PROXY"
  value: {{ printf "\"%s://%s:%s\"" (default "http" $proxy.httpProxy.protocol | toString) ($proxy.httpProxy.host | toString) ($proxy.httpProxy.port | toString) }}
        {{- end }}
      {{- end }}
      {{- if $proxy.httpsProxy }}
        {{- if and ($proxy.httpsProxy.host) ($proxy.httpsProxy.port) }}
- name: "HTTPS_PROXY"
  value: {{ printf "\"%s://%s:%s\"" (default "http" $proxy.httpsProxy.protocol | toString) ($proxy.httpsProxy.host | toString)  ($proxy.httpsProxy.port | toString) }}
        {{- end }}
      {{- end }}
      {{- if $proxy.noProxy }}
- name: "NO_PROXY"
        {{- if kindIs "slice" $proxy.noProxy }}
  value: {{ (join ", " $proxy.noProxy) | quote }}
        {{- else }}
  value: {{ $proxy.noProxy | quote }}
        {{- end }}
      {{- end }}
    {{- end }}
  {{- end }}  
{{- end -}}


{{/*
  Java Proxies <Template>
*/}}
{{ define "lib.utils.extras.java_proxy" -}}
  {{- if $.Values.global -}}
    {{- with $.Values.global.proxy -}}
      {{- $proxy := (fromYaml (include "lib.utils.strings.template" (dict "value" $.Values.global.proxy "context" $))) -}}

      {{/* Prepare NoProxy */}}
      {{- $noproxies := $proxy.noProxy  -}}
      {{- if kindIs "slice" $proxy.noProxy -}}
        {{- $noproxies = (join "|" $proxy.noProxy) -}}
      {{- end -}}

      {{/* Print Proxy String */}}
      {{- printf "-Dhttp.proxyHost=%s -Dhttp.proxyPort=%s -Dhttp.nonProxyHosts=%s -Dhttps.proxyHost=%s -Dhttps.proxyPort=%s -Dhttps.nonProxyHosts=%s" (default "" $proxy.httpProxy.host) (default "" ($proxy.httpProxy.port | toString)) $noproxies (default "" $proxy.httpsProxy.host) (default "" ($proxy.httpsProxy.port | toString)) $noproxies -}}

    {{- end -}}
  {{- end -}}
{{- end -}}


{{/*
  ExtraResources <Template>
*/}}
{{- define "lib.utils.extras.resources" -}}
  {{- if and $.Values.extraResources (kindIs "slice" $.Values.extraResources) }}
---
apiVersion: v1
kind: List
items: {{- include "lib.utils.strings.template" (dict "value" $.Values.extraResources "context" $) | nindent 2 }}
  {{- end }}
{{- end }}