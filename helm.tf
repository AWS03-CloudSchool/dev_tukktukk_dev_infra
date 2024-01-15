# argocd 네임스페이스 생성
resource "kubernetes_namespace" "argocd_namespace" {
  metadata {
    name = "argocd"
  }
  depends_on = [ helm_release.aws_load_balancer_controller ]
}

# argocd 배포
resource "helm_release" "argocd" {
  name       = "argocd"
  namespace  = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"

  set {
    name  = "server.extraArgs"
    value = "{--insecure}"
  }

  set {
    name  = "server.service.type"
    value = "NodePort"
  }

  set {
    name  = "server.service.namedTargetPort"
    value = "false"
  }

  set {
    name  = "server.ingress.enabled"
    value = "true"
  }

  depends_on = [helm_release.aws_load_balancer_controller ]
}

# nginx-ingress 네임스페이스 생성
resource "kubernetes_namespace" "nginx_ingress_namespace" {
  metadata {
    name = "ingress-nginx"
  }
  depends_on = [ helm_release.argocd ]
}

# nginx-ingress 배포
resource "helm_release" "nginx_ingress" {
  name = "ingress-nginx"
  namespace = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart = "ingress-nginx"

  set {
    name = "controller.service.type"
    value = "NodePort"
  }
  depends_on = [ kubernetes_namespace.nginx_ingress_namespace ]
}

# mysql-operator 배포
resource "kubernetes_namespace" "mysql_operator_namespace" {
    metadata {
      name = "mysql-operator"
    }
}

resource "helm_release" "mysql_operator" {
    name       = "mysql-operator"
    namespace  = "mysql-operator"
    repository = "https://mysql.github.io/mysql-operator/"
    chart      = "mysql-operator"

    depends_on = [ kubernetes_namespace.mysql_operator_namespace ]
}

resource "kubernetes_namespace" "dev_db_cluster_namespace" {
    metadata {
        name = "test-db-cluster"
    }
}

resource "helm_release" "dev_db_cluster" {
    name       = "test-db-cluster"
    namespace  = "test-db-cluster"
    repository = "https://mysql.github.io/mysql-operator/"
    chart      = "mysql-innodbcluster"

    set {
        name  = "createNamespace"
        value = "true"
    }

    set {
        name  = "credentials.root.user"
        value = "root"
    }

    set {
        name  = "credentials.root.password"
        value = "wedding05"
    }

    set {
        name  = "credentials.root.host"
        value = "%"
    }

    set {
        name  = "serverInstances"
        value = "2"
    }

    set {
        name  = "routerInstances"
        value = "1"
    }
    set {
        name = "tls.useSelfSigned"
        value = "true"
    }


    depends_on = [ kubernetes_namespace.dev_db_cluster_namespace ]
}