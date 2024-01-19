# ALB ingress 리소스 정의
resource "kubernetes_ingress_v1" "nginx_ingress" {
  metadata {
    name        = "nginx-ingress"
    namespace   = "ingress-nginx"
    annotations = {
      "kubernetes.io/ingress.class" = "alb"
      "alb.ingress.kubernetes.io/scheme" = "internet-facing"
      "alb.ingress.kubernetes.io/listen-ports" = jsonencode([{"HTTPS": 443}])
      "alb.ingress.kubernetes.io/certificate-arn" = "arn:aws:acm:ap-northeast-2:875522371656:certificate/f207c086-5546-471b-b648-58f6e625d90a"
      "alb.ingress.kubernetes.io/subnets" = join(",", aws_subnet.public[*].id)
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

# argocd ingress 정의
resource "kubernetes_ingress_v1" "argocd_ingress" {
  metadata {
    name = "argocd-ingress"
    namespace = "argocd"
    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
      "kubernetes.io/ingress.class"                = "nginx"
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

# mysql cluster ingress
# resource "kubernetes_ingress_v1" "test_db_cluster_ingress" {
#   metadata {
#     name      = "dev-db-cluster-ingress"
#     namespace = "dev-db-cluster"
#     annotations = {
#       "nginx.ingress.kubernetes.io/rewrite-target" = "/"
#       "kubernetes.io/ingress.class"                = "nginx"
#     }
#   }

#   spec {
#     rule {
#       host = "devdb.tukktukk.com"
#       http {
#         path {
#           backend {
#             service {
#               name = "dev-db-cluster"
#               port {
#                 number = 3306
#               }
#             }
#           }
#           path = "/"
#           path_type = "Prefix"
#         }
#       }
#     }
#   }

#   depends_on = [ kubernetes_ingress_v1.nginx_ingress ]
# }