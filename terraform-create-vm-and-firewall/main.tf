# Create network dedicated to this project
resource "google_compute_network" "vpc_network" {
  name                    = "my-vpc-network"
  auto_create_subnetworks = false
  mtu                     = 1460
}

# Create subnetwork 
resource "google_compute_subnetwork" "default" {
  name          = "my-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = "us-west1"
  network       = google_compute_network.vpc_network.id
}


# Create a single Compute Engine instance
resource "google_compute_instance" "default" {
  name         = "pi-hole"
  machine_type = "e2-micro"
  zone         = "us-west1-a"
  tags         = ["ssh"]
  tags         = ["ssh", "pi-hole"]

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }

  # Install Pi-Hole
  metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential; curl -sSL https://install.pi-hole.net | bash"
  metadata_startup_script = "curl -sSL https://install.pi-hole.net | sudo bash /dev/stdin --unattended"

  network_interface {
    subnetwork = google_compute_subnetwork.default.id

    access_config {
      # Include this section to give the VM an external IP address
    }
  }
}

# Allow to SSH 
resource "google_compute_firewall" "ssh" {
  name = "allow-ssh"
  allow {
    ports    = ["22"]
    protocol = "tcp"
  }
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network.id
  priority      = 1000
  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["ssh"]
}


# open port 53 - DNS
# DON'T Do this without VPN !!!
###################################


resource "google_compute_firewall" "Pi-Hole" {
# WARNING: Opening DNS to the world is a security risk (open resolver).
# It is strongly recommended to use a VPN and only allow traffic from the VPN's IP range.
# For demonstration, this is restricted to a placeholder IP.
# Replace "203.0.113.1/32" with your own IP address or VPN network range.
resource "google_compute_firewall" "pi-hole" {
  name    = "pi-hole-firewall"
  network = google_compute_network.vpc_network.id

  allow {
    protocol = "tcp"
    ports    = ["53"]
  }
  source_ranges = ["0.0.0.0/0"]
  allow {
    protocol = "udp"
    ports    = ["53"]
  }

  source_ranges = ["203.0.113.1/32"] # <-- IMPORTANT: Change this to your IP address
  target_tags   = ["pi-hole"]
}

# Extract external IP address of the VM
output "DNS-Server-IP" {
 value = join("",["http://",google_compute_instance.default.network_interface.0.access_config.0.nat_ip])
  description = "The external IP address of the Pi-hole DNS server."
  value       = google_compute_instance.default.network_interface[0].access_config[0].nat_ip
}

