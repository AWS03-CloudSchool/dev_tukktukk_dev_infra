# ALB ingress 리소스 정의

# argocd
resource "kubernetes_ingress_v1" "argocd_ingress" {
  metadata {
    name        = "argocd-ingress"
    namespace   = "argocd"
    annotations = {
      "alb.ingress.kubernetes.io/group.name"      = "tuktuk"
      "kubernetes.io/ingress.class"               = "alb"
      "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
      "alb.ingress.kubernetes.io/listen-ports"    = jsonencode([{"HTTPS": 443},{"HTTP": 80}])
      "alb.ingress.kubernetes.io/certificate-arn" = "arn:aws:acm:ap-northeast-2:875522371656:certificate/f207c086-5546-471b-b648-58f6e625d90a"
      "alb.ingress.kubernetes.io/subnets"         = join(",", aws_subnet.public[*].id)
      "alb.ingress.kubernetes.io/ssl-redirect"    = "443"
      "alb.ingress.kubernetes.io/target-type"     = "ip"
    }
  }

  spec {
    rule {
      host = "argocd.tukktukk.com"
      http {
        path {
          path = "/*"
          path_type = "ImplementationSpecific"
          backend {
            service {
              name = "argocd-server"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

# grafana
resource "kubernetes_ingress_v1" "grafana_ingress" {
  metadata {
    name        = "grafana-ingress"
    namespace   = "monitoring"
    annotations = {
      "alb.ingress.kubernetes.io/group.name"      = "tuktuk"
      "kubernetes.io/ingress.class"               = "alb"
      "alb.ingress.kubernetes.io/scheme"          = "internet-facing"
      "alb.ingress.kubernetes.io/listen-ports"    = jsonencode([{"HTTPS": 443},{"HTTP": 80}])
      "alb.ingress.kubernetes.io/certificate-arn" = "arn:aws:acm:ap-northeast-2:875522371656:certificate/f207c086-5546-471b-b648-58f6e625d90a"
      "alb.ingress.kubernetes.io/subnets"         = join(",", aws_subnet.public[*].id)
      "alb.ingress.kubernetes.io/ssl-redirect"    = "443"
      "alb.ingress.kubernetes.io/target-type"     = "ip"
    }
  }

  spec {
    rule {
      host = "grafana.tukktukk.com"
      http {
        path {
          path = "/*"
          path_type = "ImplementationSpecific"
          backend {
            service {
              name = "prometheus-grafana"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_ingress_v1" "tuktuk-ing" {
  metadata {
    name      = "tuktuk-ing"
    namespace = "tuktuk-front"

    annotations = {
      "alb.ingress.kubernetes.io/group.name"                        = "tuktuk"
      "alb.ingress.kubernetes.io/target-type"                       = "ip"
      "kubernetes.io/ingress.class"                                 = "alb"
      "alb.ingress.kubernetes.io/subnets"                           = join(",", aws_subnet.public[*].id)
      "alb.ingress.kubernetes.io/scheme"                            = "internet-facing"
      "alb.ingress.kubernetes.io/tags"                              = "Environment=dev,Owner=admin"
      "alb.ingress.kubernetes.io/listen-ports"                      = jsonencode([{"HTTPS": 443},{"HTTP": 80}])
      "alb.ingress.kubernetes.io/ssl-redirect"                      = "443"
      "alb.ingress.kubernetes.io/auth-type"                         = "cognito"
      "alb.ingress.kubernetes.io/auth-scope"                        = "openid"
      "alb.ingress.kubernetes.io/auth-session-timeout"              = "3600"
      "alb.ingress.kubernetes.io/auth-session-cookie"               = "AWSELBAuthSessionCookie"
      "alb.ingress.kubernetes.io/auth-on-unauthenticated-request"   = "authenticate"
      "alb.ingress.kubernetes.io/auth-idp-cognito"                  = jsonencode({"UserPoolArn": "arn:aws:cognito-idp:ap-northeast-2:875522371656:userpool/ap-northeast-2_CvpIITi4y", "UserPoolClientId": "mmkq2evci6d21fjs553tnibk3", "UserPoolDomain": "tuktuk"})
      "alb.ingress.kubernetes.io/certificate-arn"                   = "arn:aws:acm:ap-northeast-2:875522371656:certificate/f207c086-5546-471b-b648-58f6e625d90a"
    }
  }

  spec {
    rule {
      host = "www.tukktukk.com"

      http {
        path {
          path = "/*"
          path_type = "ImplementationSpecific"
          backend {
            service {
              name = "dev-tuktuk-front-fronttukktukk"
              port {
                number = 8080
              }
            }
          }
        }
      }
    }
  }
}

# argocd ingress 정의
# resource "kubernetes_ingress_v1" "argocd_ingress" {
#   metadata {
#     name = "argocd-ingress"
#     namespace = "argocd"
#     annotations = {
#       # "nginx.ingress.kubernetes.io/auth-response-headers" = "Authorization"
#       "nginx.ingress.kubernetes.io/rewrite-target" = "/"
#       "kubernetes.io/ingress.class"                = "nginx"
#       # "nginx.ingress.kubernetes.io/proxy-buffer-size" = "512k"
#       # "nginx.ingress.kubernetes.io/auth-signin"    = "https://$host/oauth2/start?rd=$escaped_request_uri"
#       # "nginx.ingress.kubernetes.io/auth-url"       = "https://$host/oauth2/auth"
#       # "nginx.ingress.kubernetes.io/configuration-snippet" = <<-EOF
#       #   auth_request_set $name_upstream_1 $upstream__oauth2_proxy_1;

#       #   access_by_lua_block {
#       #     if ngx.var.name_upstream_1 ~= "" then
#       #       ngx.header["Set-Cookie"] = "_oauth2_proxy_1=" .. ngx.var.name_upstream_1 .. ngx.var.auth_cookie:match("(; .*)")
#       #     end
#       #   }
#       # EOF
#     }
#   }

#   spec {
#     rule {
#       host = "${var.argocd_sub_dns}.tukktukk.com"
#       http {
#         path {
#           path = "/"
#           path_type = "Prefix"
#           backend {
#             service {
#               name = "argocd-server"
#               port {
#                 number = 80
#               }
#             }
#           }
#         }
#       }
#     }
#   }

#   depends_on = [ kubernetes_ingress_v1.nginx_ingress ]
# }

# grafana ingress 정의
# resource "kubernetes_ingress_v1" "grafana_ingress" {
#   metadata {
#     name = "grafana-ingress"
#     namespace = "monitoring"
#     annotations = {
#       "nginx.ingress.kubernetes.io/rewrite-target" = "/"
#       "kubernetes.io/ingress.class"                = "nginx"
#     }
#   }

#   spec {
#     rule {
#       host = "${var.grafana_sub_dns}.tukktukk.com"
#       http {
#         path {
#           path = "/"
#           path_type = "Prefix"
#           backend {
#             service {
#               name = "prometheus-grafana"
#               port {
#                 number = 80
#               }
#             }
#           }
#         }
#       }
#     }
#   }

#   depends_on = [ kubernetes_namespace.monitoring_namespace,kubernetes_ingress_v1.nginx_ingress ]
# }

