# Linux CloudStation
This automation uses [Terraform](https://github.com/hashicorp/terraform) to provision a Linux cloud workstation with an integrated [Code Server](https://github.com/cdr/code-server) instance.

You can now fire up your own remote Linux box and run [VScode](https://github.com/microsoft/vscode) straight from the browser. With the built-in terminal, you can go back to getting all your work done in the comfort and safety of the penguin, regardless of your local hardware.

![](https://d33wubrfki0l68.cloudfront.net/523f0c3da72d677f7cc0031bc3b85f8e83a36ea7/ec829/assets/img/vscode-pomerium.72601c46.png)

## Requirements:
### 1. [Terraform](https://terraform.io/)

## How-To:
**1.** Depending on which cloud platform you want to use, assign your chosen parameters in `terraform.tfvars`. Instructions for these parameters can be found in the respective directories.

**2.** Run `terraform init` and `terraform apply` from the platform directory of your choice.

**3.** Upon successful creation, you will receive an output with an IP address or DNS endpoint of the workstation and instructions on how to SSH into it. The default user password is `coder` and you will be prompted to set a new user password upon first SSH login.

**4.** After you have set your user password, SSH back in and run `sudo code-server-init` to enable Code Server and set a password for the web interface (make it different to your Linux user password).

  *(You can re-run `sudo code-server-init` to change your password)*

**5.** Navigate to the previously outputted IP/DNS in your browser and enjoy your new Linux workstation!

**6.** To upgrade Code Server, simply SSH in and run `sudo code-server-upgrade`.

*(Do not run upgrade from the Code Server built-in terminal as you'd be running it from the service you are modifying).*

## Using Terraform Cloud (recommended)

I recommend using [Terraform Cloud](https://www.terraform.io/docs/cloud/index.html) to remotely store the state of the deployment. This ensures that Terraform's state remains persistent regardless of your local machine/repo. You can create a free account for up to 5 users.

There is a already a placeholder (`remote_backend.tf`) in each platform directory to insert your backend config.

## The Technical Stuff:
Each cloud platform will follow the same design pattern, that being:

**1.** Fire up a VPS with Ubuntu LTS.

**2.** Provisioning a separate drive which will be mounted to `/home`. This ensures that `/home` remains persistent in the case of a corrupted VPS or if you want to spin up a fresh Linux box.

**3.** Download latest Code Server binary and running it as a native systemd service.

**4.** Assigning the Code Server config path to `~/code-server` so your VScode settings and extensions remain persistent.

**5.** Putting a load balancer in front of the VPS to leverage the capabilities of:
* Health checks
* A persistent IP for DNS (up to you to sort out TLS and DNS if you want it)
* Port redirecting to the Code Server service

**6.** In the case of a corrupted VPS, or if you want a fresh box, destroy the VPS manually via your chosen platform's console and simply run the automation again. It will reinstate a fresh instance, mount the `/home` drive, and slot it back into the existing infrastructure.

**7.** To destroy all infrastructure, run `terraform destroy` from the platform's directory.

## Future Features:
The current ideas for future iterations are:

**1.** Implement more platforms. Possibly GCP next.

**2.** Add automation for installing dev tools (possibly Ansible).

## Long Live Tux!