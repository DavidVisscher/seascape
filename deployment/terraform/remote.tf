 terraform {
  backend "remote" {
    organization = "seascape"

    workspaces {
      name = "seascape"
    }
  }
}

