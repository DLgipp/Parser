provider "yandex" {
  service_account_key_file = "key.json"
  cloud_id  = var.cloud_id
  folder_id = var.folder_id
  zone      = var.zone
}

resource "yandex_vpc_network" "network" {
  name = "parser-network"
}

resource "yandex_vpc_subnet" "subnet" {
  name           = "parser-subnet"
  zone           = var.zone
  network_id     = yandex_vpc_network.network.id
  v4_cidr_blocks = ["10.10.0.0/16"]
}

resource "yandex_kubernetes_cluster" "k8s" {
  name        = "parser-cluster"
  network_id  = yandex_vpc_network.network.id
  master {
    zonal {
      zone      = var.zone
      subnet_id = yandex_vpc_subnet.subnet.id
    }

    public_ip = true
  }

  service_account_id      = yandex_iam_service_account.k8s.id
  node_service_account_id = yandex_iam_service_account.k8s.id

  depends_on = [
    yandex_resourcemanager_folder_iam_member.k8s-editor
  ]
}

resource "yandex_kubernetes_node_group" "parser-nodes" {
  cluster_id = yandex_kubernetes_cluster.k8s.id
  name       = "parser-nodes"
  version    = "1.30"

  instance_template {
    platform_id = "standard-v3"
    resources {
      cores  = 2
      memory = 4
    }

    boot_disk {
      type = "network-hdd"
      size = 30
    }

    network_interface {
      subnet_ids = [yandex_vpc_subnet.subnet.id]
      nat        = true
    }
  }

  scale_policy {
    fixed_scale {
      size = 1
    }
  }

  allocation_policy {
    location {
      zone = var.zone
    }
  }
}

resource "yandex_iam_service_account" "k8s" {
  name = "k8s-sa"
}

resource "yandex_resourcemanager_folder_iam_member" "k8s-editor" {
  folder_id = var.folder_id
  role      = "editor"
  member    = "serviceAccount:${yandex_iam_service_account.k8s.id}"
}
