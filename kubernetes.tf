resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "nginx"
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        name = "nginx"
      }
    }

    template {
      metadata {
        labels = {
          name = "nginx"
        }
      }

      spec {
        container {
          name  = "nginx"
          image = "nginx:latest"
        }
      }
    }
  }
}

resource "kubernetes_service" "nginx" {
  metadata {
    name = "nginx"
  }

  spec {
    selector = {
      name = "nginx"
    }

    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}
