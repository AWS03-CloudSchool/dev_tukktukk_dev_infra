# innodb cluster 구축
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
        name = "dev-db-cluster"
    }
}

resource "helm_release" "dev_db_cluster" {
    name       = "dev-db-cluster"
    namespace  = "dev-db-cluster"
    repository = "https://mysql.github.io/mysql-operator/"
    chart      = "mysql-innodbcluster"

    set {
        name  = "createNamespace"
        value = "true"
    }

    set {
        name  = "credentials.root.user"
        value = var.mysql_root_username
    }

    set {
        name  = "credentials.root.password"
        value = var.mysql_root_password
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


    depends_on = [ kubernetes_namespace.dev_db_cluster_namespace , null_resource.update_storageclass ]
}