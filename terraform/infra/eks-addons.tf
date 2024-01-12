# install NGINX LB controller
resource "helm_release" "nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "kube-system"
}

# used for output NLB address
data "kubernetes_service" "nginx" {
  depends_on = [helm_release.nginx]
  metadata {
    name      = "ingress-nginx-controller"
    namespace = "kube-system"
  }
}
