# Linux CloudStation
This automation uses [Terraform](https://github.com/hashicorp/terraform) to provision a Linux cloud workstation with a built-in [Code Server](https://github.com/cdr/code-server) instance.

You can now fire up your own remote Linux box and run [VScode](https://github.com/microsoft/vscode) straight from the browser. With the built-in terminal, you can go back to getting all your work done in the comfort and safety of the penguin, regardless of your local hardware.

![](https://d33wubrfki0l68.cloudfront.net/523f0c3da72d677f7cc0031bc3b85f8e83a36ea7/ec829/assets/img/vscode-pomerium.72601c46.png)

## Requirements:
### 1. [Terraform](https://terraform.io/)

## How-To:
**1.** Depending on which cloud platform you want to use, assign your chosen parameters in `terraform.tfvars`. Instructions for these parameters can be found in the respective cloud platform directories.

**2.** Run `terraform init` and `terraform apply` from the platform directory of your choice.

**3.** Upon successful creation, you will receive an output with an IP address or DNS endpoint of the workstation and your passwords for both the Linux user and Code Server web UI.

**6.** Code Server is installed via a .deb package and upgraded/managed via apt.

## Using Terraform Cloud (recommended)

I recommend using [Terraform Cloud](https://www.terraform.io/docs/cloud/index.html) to remotely store the state of the deployment. This ensures that Terraform's state remains persistent regardless of your local machine/repo. You can create a free account for up to 5 users.

## The Technical Stuff:
Each cloud platform will follow the same design pattern, that being:

**1.** Fire up a VPS with the latest Ubuntu LTS.

**2.** Apply an appropriate network-layer firewall for optimal security.

**2.** Provision a separate drive which will be mounted to `/home`. This ensures that `/home` and your Code Server config remains persistent in the case of a corrupted VPS or if you want to spin up a fresh Linux box.

**3.** Download and install the latest Code Server release via native package manager.

## Future Features:
The current ideas for future iterations are:

**1.** Implement more platforms. Possibly AWS next.

**2.** Add automation for installing dev tools (possibly Ansible).

## Long Live Tux!
