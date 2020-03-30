# UTD Automation by Palo Alto Networks
Use PAN-OS API with Terraform and Ansible to deploy a single VPC architecture



## Getting Started

Instructor Guide
See readthedocs

### Prerequisites

#### AWS Account

2 scenarios
Create the env
Create one account per student or refresh the password


Student can bring their own account if wanted

#### Systems

Create one VM per student with the following script
Terraform used here
AWS account required

#### IAM Users

Create an admin account to handle the UTD

### Changes

Change IP from Logstash and Kibana to point toward Elasticsearch IP

---
1. *aws account*
```
$ export AWS_ACCESS_KEY_ID=your-access-key-here
$ export AWS_SECRET_ACCESS_KEY=your-secret-key-here
```

2. *number or users*
```
aws.ami.number: NUMBER OF STUDENTS
```

---

### Ubuntu 18.04 LTS

Installation on Ubuntu LTS 18.04

```

```

## To Do
​
**Next steps**
- [x] Create utd-admin
- [ ] create user group for utds
- [x] Guacamole
- [ ] NGINX
- [ ] Let's Encrypt
- [ ] Automate stuff
​- [ ] Separate in 3 gits, DOC, INSTRUCTOR, UTD

**Optional**
- [ ] 
- [ ] 
- [ ] 

## References


## Authors

* **Victor Knell** - *main author*
* **Franck Verstraete** - *main author*
* **Damien Raynal** - *initial work*
* **Hamza Sahli** - *initial work*

### Contributors 


## License
​
This project is licensed under the MIT License - see the [LICENSE.md](https://github.com/damray/panelk/blob/master/LICENSE.md) file for details