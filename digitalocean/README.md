# Digital Ocean
You will need to export your [Digital Ocean API token](https://www.digitalocean.com/docs/api/create-personal-access-token/) as `DIGITALOCEAN_TOKEN` to authenticate Terraform.

By default, this stack builds a Droplet with an NGINX reverse proxy which accepts and passes HTTP traffic through to the Code Server port `:8080` on the instance. For optimal security, I recommend using a TLS-certified domain against the instance public IP. This can be easily added into the existing NGINX webserver with the [following guide](https://www.scaleway.com/en/docs/how-to-configure-nginx-reverse-proxy/#-Adding-TLS-to-your-Nginx-Reverse-Proxy-using-Lets-Encrypt).

_**FYI:** Digital Ocean user data can take a few minutes to execute sometimes. If the Code Server endpoint initially returns a 503, 404 or you are unable to SSH in, this just means the user data hasn't finished executing yet._

## Digital Ocean parameters in [terraform.tvfars](terraform.tfvars):

**hostname:** The Linux hostname. *(This will also be used to name a few other Digital Ocean resources like load balancer, firewall, project etc.)*

**username:** The Linux username.

**region:** The Digital Ocean data center region. Options include:

    nyc1, nyc2, nyc3: New York City, United States
    ams2, ams3      : Amsterdam, the Netherlands
    sfo1, sfo2      : San Francisco, United States
    sgp1            : Singapore
    lon1            : London, United Kingdom
    fra1            : Frankfurt, Germany
    tor1            : Toronto, Canada
    blr1            : Bangalore, India

**droplet_size:** The droplet size. Standard options include:

*A full list of all droplet sizes and costs can be [found here](https://slugs.do-api.dev/).*

    s-1vcpu-1gb
    s-1vcpu-2gb
    s-1vcpu-3gb
    s-2vcpu-2gb
    s-2vcpu-4gb
    s-3vcpu-1gb
    s-4vcpu-8gb
    s-6vcpu-16gb
    s-8vcpu-32gb
    s-12vcpu-48gb
    s-16vcpu-64gb
    s-20vcpu-96gb
    s-24vcpu-128gb
    s-32vcpu-192gb

**storage_size:** The size *(in GB)* of the persistent disk that will be mounted to `/home`.

**github_username:** Your GitHub username. This will import the SSH keys associated with your GitHub account to the created user so you can SSH into the EC2 instance if needed.