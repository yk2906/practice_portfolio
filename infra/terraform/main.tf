provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

locals {
  name_prefix = "portfolio"
  network     = "${local.name_prefix}-net"
  subnet      = "${local.name_prefix}-subnet"
  tags        = ["portfolio-web"]
}

# VPC
resource "google_compute_network" "vpc" {
  name                    = local.network
  auto_create_subnetworks = false
}

# Subnet
resource "google_compute_subnetwork" "subnet" {
  name          = local.subnet
  ip_cidr_range = "10.10.0.0/24"
  region        = var.region
  network       = google_compute_network.vpc.id
}

# Firewall: HTTP
resource "google_compute_firewall" "allow_http" {
  name    = "${local.name_prefix}-allow-http"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  target_tags   = local.tags
  source_ranges = ["0.0.0.0/0"]
}

# Firewall: HTTPS (今は使わなくてもOK。あとでドメイン入れたら活きる)
resource "google_compute_firewall" "allow_https" {
  name    = "${local.name_prefix}-allow-https"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["443"]
  }

  target_tags   = local.tags
  source_ranges = ["0.0.0.0/0"]
}

# Firewall: SSH (最初からIP制限推奨)
resource "google_compute_firewall" "allow_ssh" {
  name    = "${local.name_prefix}-allow-ssh"
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  target_tags   = local.tags
  source_ranges = var.allowed_ssh_cidrs
}

# VM
resource "google_compute_instance" "vm" {
  name         = "${local.name_prefix}-vm"
  machine_type = "e2-micro"
  zone         = var.zone
  tags         = local.tags

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2404-lts-amd64"
      type  = "pd-standard" # 무료枠寄せなら標準ディスク
      size  = 30            # まずは30GB
    }
  }

  network_interface {
    subnetwork = google_compute_subnetwork.subnet.id
    access_config {} # これで外部IP（エフェメラル）が付く
  }

  metadata = {
    # SSH公開鍵を登録（OS Login使うなら別方式でもOK）
    "ssh-keys" = "${var.ssh_username}:${file(var.ssh_public_key_path)}"
  }

  # お好み：ここでNginxを入れておくと「作ったら即表示」になる
  metadata_startup_script = <<-EOT
    #!/usr/bin/env bash
    set -euxo pipefail
    apt-get update
    apt-get install -y nginx
    systemctl enable --now nginx
  EOT
}
