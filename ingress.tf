# ALB ingress 리소스 정의
resource "kubernetes_ingress_v1" "nginx_ingress" {
  metadata {
    name        = "nginx-ingress"
    namespace   = "ingress-nginx"
    annotations = {
      "kubernetes.io/ingress.class" = "alb"
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/listen-ports" = jsonencode([{"HTTPS": 443},{"HTTP": 80}])
      "alb.ingress.kubernetes.io/certificate-arn" = "arn:aws:acm:ap-northeast-2:875522371656:certificate/f207c086-5546-471b-b648-58f6e625d90a"
      "alb.ingress.kubernetes.io/subnets" = join(",", aws_subnet.public[*].id)
      "alb.ingress.kubernetes.io/ssl-redirect" = "443"
    }
    labels = {
      "app" = "nginx-ingress"
    }
  }

  spec {
    rule {
      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "ingress-nginx-controller"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [ helm_release.nginx_ingress ]
}

# keycloak ingress 배포
resource "kubernetes_ingress_v1" "keycloak_ingress" {
  metadata {
    name        = "keycloak-ingress"
    namespace   = "keycloak"
    annotations = {
      "kubernetes.io/ingress.class" = "alb"
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/target-type" =  "ip"
      "alb.ingress.kubernetes.io/listen-ports" = jsonencode([{"HTTP": 80},{"HTTPS": 443}])
      "alb.ingress.kubernetes.io/certificate-arn" = "arn:aws:acm:ap-northeast-2:875522371656:certificate/f207c086-5546-471b-b648-58f6e625d90a"
      "alb.ingress.kubernetes.io/subnets" = join(",", aws_subnet.public[*].id)
    }
  }

  spec {
    
    rule {
      host = "keycloak.tukktukk.com"

      http {
        path {
          path      = "/"
          path_type = "Prefix"
          backend {
            service {
              name = "keycloak"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [ helm_release.keycloak,helm_release.nginx_ingress ]
}

# argocd ingress 정의
resource "kubernetes_ingress_v1" "argocd_ingress" {
  metadata {
    name = "argocd-ingress"
    namespace = "argocd"
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
      "kubernetes.io/ingress.class"                = "nginx"
      "nginx.ingress.kubernetes.io/auth-signin"    = "https://$host/oauth2/start?rd=$escaped_request_uri"
      "nginx.ingress.kubernetes.io/auth-url"       = "https://$host/oauth2/auth"
      "nginx.ingress.kubernetes.io/proxy-buffer-size" = "512k"
    }
  }

  spec {
    rule {
      host = "${var.argocd_sub_dns}.tukktukk.com"
      http {
        path {
          path = "/"
          path_type = "Prefix"
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

  depends_on = [ kubernetes_ingress_v1.nginx_ingress ]
}

# grafana ingress 정의
resource "kubernetes_ingress_v1" "grafana_ingress" {
  metadata {
    name = "grafana-ingress"
    namespace = "monitoring"
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
      "kubernetes.io/ingress.class"                = "nginx"
    }
  }

  spec {
    rule {
      host = "${var.grafana_sub_dns}.tukktukk.com"
      http {
        path {
          path = "/"
          path_type = "Prefix"
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

  depends_on = [ kubernetes_namespace.monitoring_namespace,kubernetes_ingress_v1.nginx_ingress ]
}

