# AWS
You will need to export your [IAM User Access Keys](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html) as `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` to authenticate Terraform.

By default, this stack builds an EC2 with an NGINX reverse proxy which accepts and passes HTTP traffic through to the Code Server port `:8080` on the instance. For optimal security, I recommend using a TLS-certified domain against the instance public IP. This can be easily added into the existing NGINX webserver with the [following guide](https://www.scaleway.com/en/docs/how-to-configure-nginx-reverse-proxy/#-Adding-TLS-to-your-Nginx-Reverse-Proxy-using-Lets-Encrypt).

_**FYI:** AWS user data can take a few minutes to execute sometimes. If the Code Server endpoint initially returns a 503, 404 or you are unable to SSH in, this just means the user data hasn't finished executing yet._

## AWS parameters in [terraform.tvfars](terraform.tfvars):

**hostname:** The Linux hostname. *(This will also be used to name a few other AWS resources like VPC, EC2, Security Group etc.)*

**username:** The Linux username.

**region:** The AWS region. A list of regional endpoints can be found [here](https://docs.aws.amazon.com/general/latest/gr/rande.html#regional-endpoints).

**instance_size:** The EC2 instance size. A list of EC2 instance sizes can be found [here](https://aws.amazon.com/ec2/instance-types/). I recommend T3 instances as they are cheap and more than capable for running Code Server.

**storage_size:** The size *(in GB)* of the persistent disk that will be mounted to `/home`.

**github_username:** Your GitHub username. This will import the SSH keys associated with your GitHub account to the created user so you can SSH into the EC2 instance if needed.