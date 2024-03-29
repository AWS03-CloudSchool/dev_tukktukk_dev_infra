resource "kubernetes_namespace" "tuktuk_backend" {
  metadata {
    name = "tuktuk-backend"
  }

}

resource "kubernetes_secret" "be_secrets" {
  metadata {
    name = "be-secrets"
    namespace = "tuktuk-backend"
  }

  type = "Opaque"

  data = {
    DATABASE_URL        = var.be_database_url
    MYSQL_ROOT_USERNAME = var.mysql_root_username
    MYSQL_ROOT_PASSWORD = var.mysql_root_password
    AWS_ACCESS_KEY      = var.be_access_key
    AWS_SECRET_KEY      = var.be_secret_key
    AWS_SERVICE_REGION  = var.aws_region
    S3_BUCKET_NAME      = var.be_bucket_name
    COGNITO_ISSUER_URI  = var.cognito_issuer_uri
    COGNITO_REDIRECT_URI = var.cognito_redirect_uri
    COGNITO_TOKEN_ENDPOINT = var.cognito_token_endpoint
    COGNITO_CLIENT_ID   = var.cognito_client_id
    COGNITO_CLIENT_NAME = var.cognito_client_name
    COGNITO_CLIENT_SECRET = var.cognito_client_secret
  }

  depends_on = [ kubernetes_namespace.tuktuk_backend ]
}