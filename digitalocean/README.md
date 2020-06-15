# Digital Ocean
You will need to export your [Digital Ocean API token](https://www.digitalocean.com/docs/api/create-personal-access-token/) as `DIGITALOCEAN_TOKEN` to authenticate Terraform.

By default, this stack builds a [load balancer](https://www.digitalocean.com/docs/networking/load-balancers/) which accepts and passes HTTP traffic through to the Code Server port `:8080` on the droplet. For optimal security, I recommend using a TLS-certified domain and forcing HTTPS on the load balancer. An easy managed way to achieve this on Digital Ocean can be found [here](https://www.digitalocean.com/docs/networking/load-balancers/how-to/ssl-termination/).

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

**ssh_key_id:** Your [Digital Ocean SSH key ID](https://developers.digitalocean.com/documentation/v2/#list-all-keys). These are 8-digit numbers that map to SSH keys linked on your Digital Ocean account and are required to authenticate connections to the droplet.

To find your SSH Key ID, run the following command, replacing `DO_API_TOKEN` with your Digital Ocean API token.

```
curl -X GET -H "Content-Type: application/json" -H "Authorization: Bearer DO_API_TOKEN" "https://api.digitalocean.com/v2/account/keys"
````

The response body will look like this. Grab the 8-digit ID number.

```
{
  "ssh_keys": [
    {
      "id": 512189,
      "fingerprint": "3b:16:bf:e4:8b:00:8b:b8:59:8c:a9:d3:f0:19:45:fa",
      "public_key": "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAQQDDHr/jh2Jy4yALcK4JyWbVkPRaWmhck3IgCoeOO3z1e2dBowLh64QAM+Qb72pxekALga2oi4GvT+TlWNhzPH4V example",
      "name": "My SSH Public Key"
    }
  ],
  "links": {
  },
  "meta": {
    "total": 1
  }
}
```

If you have not added your SSH key to your Digital Ocean account, instructions to do so can be found [here](https://www.digitalocean.com/docs/droplets/how-to/add-ssh-keys/to-account/).